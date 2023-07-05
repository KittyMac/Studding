import Foundation
import Hitch

fileprivate let TBXML_ATTRIBUTE_NAME_START = 0
fileprivate let TBXML_ATTRIBUTE_NAME_END = 1
fileprivate let TBXML_ATTRIBUTE_VALUE_START = 2
fileprivate let TBXML_ATTRIBUTE_VALUE_END = 3
fileprivate let TBXML_ATTRIBUTE_CDATA_END = 4

extension Studding {

    @usableFromInline
    internal enum Reader {

        @usableFromInline
        internal static func parsed<T>(hitch: Hitch, _ callback: (XmlElement?) -> T?) -> T? {
            return parsed(halfhitch: hitch.halfhitch(), callback)
        }
 
        @usableFromInline
        internal static func parsed<T>(string: String, _ callback: (XmlElement?) -> T?) -> T? {
            return parsed(halfhitch: HalfHitch(string: string), callback)
        }

        @usableFromInline
        internal static func parsed<T>(data: Data, _ callback: (XmlElement?) -> T?) -> T? {
            return HalfHitch.using(data: data) { json in
                return parsed(halfhitch: json, callback)
            }
        }

        @usableFromInline
        internal static func parsed<T>(halfhitch json: HalfHitch, _ callback: (XmlElement?) -> T?) -> T? {
            callback(parse(halfhitch: json))
        }

        @usableFromInline
        internal static func parse(halfhitch string: HalfHitch) -> XmlElement? {
            // based on TBXML: https://github.com/codebots-ltd/TBXML
            
            guard let raw = string.raw() else { return nil }
            let rawEnd = raw + string.count
            
            // set elementStart pointer to the start of our xml
            var elementStart: UnsafePointer<UInt8> = raw
            
            var xmlElementStack: [XmlElement] = [
                XmlElement()
            ]
            
            var textStart: UnsafePointer<UInt8>? = nil
            
            let p: ()->() = {
                printAround(halfHitch: string,
                            start: raw,
                            end: rawEnd,
                            ptr: elementStart)
            }
            
            // find next element start
            while true {
                elementStart = strstr1(elementStart, rawEnd, .lessThan)
                guard elementStart < rawEnd else { break }
                
                // finish the text content of the previous element if there is one
                if let parentXmlElement = xmlElementStack.last,
                   parentXmlElement.children.isEmpty,
                   let textStart = textStart {
                    parentXmlElement.text = HalfHitch(source: string,
                                                      from: textStart - raw,
                                                      to: elementStart - raw)
                }

                // detect comment section
                if strncmp(elementStart, rawEnd, "<!--") == 0 {
                    elementStart = strstr(elementStart, rawEnd, "-->") + 3
                    continue
                }
                
                // detect cdata section within element text
                let isCDATA = strncmp(elementStart, rawEnd, "<![CDATA[")
                
                // if cdata section found, skip data within cdata section and remove cdata tags
                if (isCDATA == 0) {
                    elementStart += 9
                    
                    // find end of cdata section
                    let CDATAEnd = strstr(elementStart, rawEnd, "]]>")
                    
                    if let parentXmlElement = xmlElementStack.last {
                        parentXmlElement.cdata.append(
                            HalfHitch(source: string,
                                      from: elementStart - raw,
                                      to: CDATAEnd - raw)
                        )
                    }
                                        
                    // find start of next element skipping any cdata sections within text
                    var elementEnd = CDATAEnd
                    
                    // find next open tag
                    elementEnd = strstr1(elementEnd, rawEnd, .lessThan)
                    
                    // if open tag is a cdata section
                    while strncmp(elementEnd, rawEnd, "<![CDATA[") == 0 {
                        let elementStart = elementEnd + 9
                        
                        // find end of cdata section
                        elementEnd = strstr(elementEnd, rawEnd, "]]>")
                        
                        if let parentXmlElement = xmlElementStack.last {
                            parentXmlElement.cdata.append(
                                HalfHitch(source: string,
                                          from: elementStart - raw,
                                          to: elementEnd - raw)
                            )
                        }
                                                
                        // find next open tag
                        elementEnd = strstr1(elementEnd, rawEnd, .lessThan)
                    }
                                        
                    // set new search start position
                    elementStart = elementEnd
                }
                
                // find element end, skipping any cdata sections within attributes
                var elementEnd = elementStart + 1
                while true {
                    elementEnd = strpbrk(elementEnd, rawEnd, .lessThan, .greaterThan)
                    if strncmp(elementEnd, rawEnd, "<![CDATA[") == 0 {
                        elementEnd = strstr3(elementEnd, rawEnd, .closeBracket, .closeBracket, .greaterThan) + 3
                    } else {
                        break
                    }
                }
                
                guard elementEnd < rawEnd else { break }
                
                // get element name start
                let elementNameStart = elementStart + 1
                
                // ignore tags that start with ? or ! unless cdata "<![CDATA"
                if elementNameStart[0] == .questionMark ||
                    elementNameStart[0] == .bang &&
                    isCDATA != 0 {
                    elementStart = elementEnd + 1
                    continue;
                }
                
                // ignore attributes/text if this is a closing element
                if elementNameStart[0] == .forwardSlash {
                    elementStart = elementEnd + 1
                    
                    _ = xmlElementStack.popLast()
                    if let parentXmlElement = xmlElementStack.last {
                        parentXmlElement.text = hitchNone
                    }
                    continue;
                }
                
                // is this element opening and closing
                var selfClosingElement = false
                if elementEnd[-1] == .forwardSlash {
                    selfClosingElement = true
                }
                
                // create new xmlElement struct
                let xmlElement = XmlElement()
                
                // in the following xml the ">" is replaced with \0 by elementEnd.
                // element may contain no atributes and would return nil while looking for element name end
                // <tile>
                // find end of element name
                let elementNameEnd = strpbrk(elementNameStart, rawEnd, .space, .forwardSlash, .newLine, .lessThan, .carriageReturn, .tab, .greaterThan)
                guard elementNameEnd < rawEnd else { break }

                // set element name
                xmlElement.name = HalfHitch(source: string,
                                            from: elementNameStart - raw,
                                            to: elementNameEnd - raw)
                
                // if there is a parent element
                if let parentXmlElement = xmlElementStack.last {
                    parentXmlElement.children.append(xmlElement)
                }
                
                // if end was found check for attributes
                var chr = elementNameEnd
                var nameStart: UnsafePointer<UInt8>? = nil
                var nameEnd: UnsafePointer<UInt8>? = nil
                var valueStart: UnsafePointer<UInt8>? = nil
                var valueEnd: UnsafePointer<UInt8>? = nil
                //var CDATAStart: UnsafePointer<UInt8>? = nil
                //var CDATAEnd: UnsafePointer<UInt8>? = nil
                var singleQuote = false
                
                var mode = TBXML_ATTRIBUTE_NAME_START
                
                // loop through all characters within element
                while chr < elementEnd {
                    chr += 1
                    
                    switch mode {
                    case TBXML_ATTRIBUTE_NAME_START:
                        // look for start of attribute name
                        if isspace(chr[0]) { continue }
                        nameStart = chr
                        mode = TBXML_ATTRIBUTE_NAME_END
                        break
                    case TBXML_ATTRIBUTE_NAME_END:
                        // look for end of attribute name
                        if isspace(chr[0]) || chr[0] == .equal {
                            nameEnd = chr
                            mode = TBXML_ATTRIBUTE_VALUE_START
                        }
                        break
                    case TBXML_ATTRIBUTE_VALUE_START:
                        // look for start of attribute value
                        if isspace(chr[0]) { continue }
                        if chr[0] == .doubleQuote || chr[0] == .singleQuote {
                            valueStart = chr + 1
                            mode = TBXML_ATTRIBUTE_VALUE_END
                            if chr[0] == .singleQuote {
                                singleQuote = true
                            } else {
                                singleQuote = false
                            }
                        }
                        break
                    
                    case TBXML_ATTRIBUTE_VALUE_END:
                        // look for end of attribute value
                        if chr[0] == .lessThan && strncmp(chr, rawEnd, "<![CDATA[") == 0 {
                            mode = TBXML_ATTRIBUTE_CDATA_END
                        } else if (chr[0] == .doubleQuote && singleQuote == false) || (chr[0] == .singleQuote && singleQuote == true) {
                            valueEnd = chr
                            
                            // create new attribute
                            if let nameStart = nameStart,
                               let nameEnd = nameEnd,
                               let valueStart = valueStart,
                               let valueEnd = valueEnd {
                                
                                let name = HalfHitch(source: string,
                                                     from: nameStart - raw,
                                                     to: nameEnd - raw)
                                
                                let value = HalfHitch(source: string,
                                                      from: valueStart - raw,
                                                      to: valueEnd - raw)
                                xmlElement.attributeNames.append(name)
                                xmlElement.attributeValues.append(value)
                            }
                            
                            // clear name and value pointers
                            nameStart = nil
                            nameEnd = nil
                            valueStart = nil
                            valueEnd = nil
                            
                            // start looking for next attribute
                            mode = TBXML_ATTRIBUTE_NAME_START
                        }
                        break
                    case TBXML_ATTRIBUTE_CDATA_END:
                        if chr[0] == .closeBracket {
                            if strncmp(chr, rawEnd, "]]>") == 0 {
                                mode = TBXML_ATTRIBUTE_VALUE_END
                            }
                        }
                        break
                    default:
                        #if DEBUG
                        fatalError("unknown attribute parsing mode")
                        #endif
                        break
                    }
                }
                
                
                // if tag is not self closing, set parent to current element
                if selfClosingElement == false {
                    
                    xmlElementStack.append(xmlElement)
                    
                    // set text on element to element end+1
                    textStart = elementEnd + 1
                }
                
                // start looking for next element after end of current element
                elementStart = elementEnd + 1
            }
            
            #if DEBUG
            if xmlElementStack.count != 1 {
                //fatalError("unbalanced xmlElementStack")
            }
            #endif
            
            return xmlElementStack.first?.children.first
            
        }
    }
}

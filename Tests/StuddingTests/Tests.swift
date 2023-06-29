import XCTest
import class Foundation.Bundle

import Studding
import Hitch

class StuddingTests: TestsBase {
    
    func test_s3_simple0() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><Element/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let root = XmlElement(name: "Element")
        XCTAssertEqual(root.toString(), xml)
    }
    
    func test_s3_simple1() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><Element key="value"/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let root = XmlElement(name: "Element",
                              attributes: [
                                "key": "value"
                              ])
        XCTAssertEqual(root.toString(), xml)
    }
    
    func test_s3_simple2() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><Element key0="value0" key1="value1"/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let root = XmlElement(name: "Element",
                              attributes: [
                                "key0": "value0",
                                "key1": "value1"
                              ])
        XCTAssertEqual(root.toString(), xml)
    }
    
    func test_s3_simple3() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><A><B/></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let a = XmlElement(name: "A",
                           children: [
            XmlElement(name: "B")
        ])
        XCTAssertEqual(a.toString(), xml)
    }
    
    func test_s3_simple4() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><A><B/><C/><D/></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let a = XmlElement(name: "A",
                           children: [
            XmlElement(name: "B"),
            XmlElement(name: "C"),
            XmlElement(name: "D")
        ])
        XCTAssertEqual(a.toString(), xml)
    }
    
    func test_s3_simple5() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><A><B><C><D/></C></B></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let d = XmlElement(name: "D")
        let c = XmlElement(name: "C", children: [d])
        let b = XmlElement(name: "B", children: [c])
        let a = XmlElement(name: "A", children: [b])
        XCTAssertEqual(a.toString(), xml)
    }
    
    func test_s3_simple6() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><A>Hello World</A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let a = XmlElement(name: "A", text: "Hello World")
        XCTAssertEqual(a.toString(), xml)
    }
    
    func test_s3_listbucket() {
        let xml = s3ListBucket
        xml.parsed { result in
            
            if let result = result {
                print(result["Name"]!.text)
                print(result["Contents"]!["Owner"]!["ID"]!.text)
            }
            
            print(result!)
            
            XCTAssertEqual(result?.description.replacingOccurrences(of: " ", with: ""), xml.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: ""))
        }
    }
    
    func test_s3_cdata() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" ?><Element><![CDATA[0123456789]]><![CDATA[ABCDEFGHIJKLMNOPQRSTUVWXYZ]]></Element>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
        
        let a = XmlElement(name: "Element",
                           cdata: [
                            "0123456789",
                            "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
       ])
        XCTAssertEqual(a.toString(), xml)
    }
    
}


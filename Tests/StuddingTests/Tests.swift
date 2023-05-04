import XCTest
import class Foundation.Bundle

import Studding
import Hitch

class SpankerTests: TestsBase {
    
    func test_s3_simple0() {
        let xml = """
        <Element/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple1() {
        let xml = """
        <Element key="value"/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple2() {
        let xml = """
        <Element key0="value0" key1="value1"/>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple3() {
        let xml = """
        <A><B/></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple4() {
        let xml = """
        <A><B/><C/><D/></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple5() {
        let xml = """
        <A><B><C><D/></C></B></A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_simple6() {
        let xml = """
        <A>Hello World</A>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
    
    func test_s3_listbucket() {
        let xml = s3ListBucket
        xml.parsed { result in
            
            if let result = result {
                print(result["Name"]!.text)
                print(result["Contents"]!["Owner"]!["ID"]!.text)
            }
            
            print(result!)
            
            XCTAssertEqual(result?.description, xml.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: ""))
        }
    }
    
    func test_s3_cdata() {
        let xml = """
        <Element><![CDATA[0123456789]]><![CDATA[ABCDEFGHIJKLMNOPQRSTUVWXYZ]]></Element>
        """
        xml.parsed { result in
            XCTAssertEqual(result?.description, xml)
        }
    }
}


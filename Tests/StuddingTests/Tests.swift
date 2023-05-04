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
    /*
    func test_s3_cdata() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Element>
            <![CDATA[0123456789]]>
            <![CDATA[ABCDEFGHIJKLMNOPQRSTUVWXYZ]]>
        </Element>
        """
        xml.parsed { result in
            
            print(result)
            
            //XCTAssertEqual(json, result?.description)
        }
    }
    
    func test_s3_listbucket() {
        let xml = s3ListBucket
        xml.parsed { result in
            
            print(result)
            
            //XCTAssertEqual(json, result?.description)
        }
    }
    */
    }

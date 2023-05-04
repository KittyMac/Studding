import XCTest
import class Foundation.Bundle

import Studding

public class TestsBase: XCTestCase {
    
    let s3ListBucket = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
            <Name>sp-rover-unittest-west</Name>
            <Prefix/>
            <Marker/>
            <MaxKeys>1000</MaxKeys>
            <IsTruncated>false</IsTruncated>
            <Contents>
                <Key>v1/errorlogs/test.txt</Key>
                <LastModified>2023-05-04T11:18:45.000Z</LastModified>
                <ETag>"ed4707d6394c613db733e650d97f39b9"</ETag>
                <Size>20</Size>
                <Owner>
                    <ID>affd54b3815886d9dfc6ee72864a8ea4d46b873549b3e32e1567bc39f9aa69b6</ID>
                    <DisplayName>drew.cogbill</DisplayName>
                </Owner>
                <StorageClass>STANDARD</StorageClass>
            </Contents>
        </ListBucketResult>
    """
}

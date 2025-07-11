//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 Truvideo. All rights reserved.
//

import Foundation

public let createMediaResponse = mockCreateMediaResponse(
    with: "https://sdk-mobile-beta.s3.us-west-2.amazonaws.com/media/FD4DAF1A-A2AA-2020-JSJS-3FB7B4A7A2EA.mp4"
)

public func mockCreateMediaResponse(with url: String, tagKey: String = "foo", tagValue: String = "var") -> String {
"""
    {
        "id": "effc5a2f-72ce-4ab2-8329-bc034211747d",
        "createdDate": "2024-04-11T19:57:07Z",
        "metadata": "{\\"key\\":\\"value\\"}",
        "tags": {
            "\(tagKey)": "\(tagValue)"
        },
        "url": "\(url)",
        "type": "IMAGE"
    }
"""
}

public func mockCreateMediaResponse(
    with url: String,
    tagKey: String = "foo",
    tagValue: String = "var",
    metadataArrayKey: String = "key",
    metadataArrayValue: String = "value",
    metadataObjectKey: String = "object",
    metadataObjectValue: String = "value"
) -> String {
"""
    {
        "id": "effc5a2f-72ce-4ab2-8329-bc034211747d",
        "createdDate": "2024-04-11T19:57:07Z",
        "metadata": "{\\"key\\":\\"value\\",\\"\(metadataArrayKey)\\":[\\"\(metadataArrayValue)\\"],\\"nested\\":{\\"\(metadataObjectKey)\\":\\"\(metadataObjectValue)\\"}}",
        "tags": {
            "\(tagKey)": "\(tagValue)"
        },
        "url": "\(url)",
        "type": "IMAGE"
    }
"""
}

public let searchMediaResponse = 
"""
{
    "content": [
        {
            "id": "effc5a2f-72ce-4ab2-8329-bc034211747d",
            "createdDate": "2024-04-11T19:57:07Z",
            "url": "https://sdk-mobile-beta.s3.us-west-2.amazonaws.com/media/FD4DAF1A-A2AA-2020-JSJS-3FB7B4A7A2EA.mp4",
            "type": "IMAGE"
        },
        {
            "id": "effc5a2f-72ce-4ab2-8329-bc034211747d",
            "createdDate": "2024-04-11T19:57:07Z",
            "metadata": "{\\"key\\":\\"value\\"}",
            "transcriptionLength": "a",
            "tags": {
                "tags": "foo"
            },
            "url": "https://sdk-mobile-beta.s3.us-west-2.amazonaws.com/media/FD4DAF1A-A2AA-2020-JSJS-3FB7B4A7A2EA.mp4",
            "type": "IMAGE"
        }
    ],
    "pageable": {
        "sort": {
            "unsorted": true,
            "sorted": false,
            "empty": true
        },
        "pageNumber": 0,
        "pageSize": 20,
        "offset": 0,
        "paged": true,
        "unpaged": false
    },
    "totalPages": 162,
    "totalElements": 3237,
    "last": false,
    "numberOfElements": 20,
    "size": 20,
    "number": 0,
    "sort": {
        "unsorted": true,
        "sorted": false,
        "empty": true
    },
    "first": true,
    "empty": false
}
"""

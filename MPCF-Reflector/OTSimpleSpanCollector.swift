//
//  OTSimpleSpanCollector.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 4/30/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import OpenTelemetryModels

// something that allows me to collect, and later transfer, a bunch of spans...

class OTSimpleSpanCollector: NSObject {

    private var spanBucket: Set<OpenTelemetry.Span> = Set()

    func collectSpan(_ span: OpenTelemetry.Span?) -> Void {
        if let span = span {
            spanBucket.insert(span)
        }
    }
    
}

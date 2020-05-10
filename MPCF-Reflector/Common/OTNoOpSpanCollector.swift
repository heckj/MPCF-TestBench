//
//  OTNoOpSpanCollector.swift
//  MPCF-Reflector-tvOS
//
//  Created by Joseph Heck on 5/10/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import OpenTelemetryModels

// something that allows me to collect, and later transfer, a bunch of spans...

class OTNoOpSpanCollector: NSObject, OTSpanCollector {

    var spanCollection: [OpenTelemetry.Span] = []
    func collectSpan(_ span: OpenTelemetry.Span?) {
    }

}

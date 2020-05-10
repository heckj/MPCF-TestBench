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

class OTSimpleSpanCollector: NSObject, OTSpanCollector, ObservableObject {

    @Published var spanCollection: [OpenTelemetry.Span] = []

    func collectSpan(_ span: OpenTelemetry.Span?) {
        if let span = span {
            spanCollection.append(span)
        }
    }

}

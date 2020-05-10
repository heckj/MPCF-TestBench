//
//  OTSpanCollector.swift
//  MPCF-Reflector
//
//  Created by Joseph Heck on 5/10/20.
//  Copyright © 2020 JFH Consulting. All rights reserved.
//

import Foundation
import OpenTelemetryModels

/// protocol description for collecting OpenTelemetry spans.
protocol OTSpanCollector {
    var spanCollection: [OpenTelemetry.Span] { get }
    func collectSpan(_ span: OpenTelemetry.Span?)
}

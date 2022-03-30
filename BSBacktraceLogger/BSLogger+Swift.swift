//
//  BSLogger+Swift.swift
//  BSBacktraceLogger
//
//  Created by Ruswan Efendi on 29/03/22.
//  Copyright © 2022 Ruswan Efendi. All rights reserved.
//

import Foundation

extension BSLogger {
	
	func print() {
		let currentThread = Thread.current
		Swift.print(BSLogger.bs_backtrace(of: currentThread) ?? "No stacktrace found")
	}
}

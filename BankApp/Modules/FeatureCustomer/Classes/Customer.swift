//
//  Customer.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 30/09/2026.
//

import Foundation

/// Domain entity — the registration data shown on the Customer screen.
/// Optional fields reflect what the OBP sandbox customer record may or
/// may not have filled in for a given test user.
public struct Customer: Equatable {
    public let customerId: String
    public let customerNumber: String?
    public let legalName: String?
    public let email: String?
    public let mobilePhoneNumber: String?
    public let dateOfBirth: Date?
    public let kycStatus: Bool?
    public let employmentStatus: String?
    public let relationshipStatus: String?

    public init(
        customerId: String,
        customerNumber: String?,
        legalName: String?,
        email: String?,
        mobilePhoneNumber: String?,
        dateOfBirth: Date?,
        kycStatus: Bool?,
        employmentStatus: String?,
        relationshipStatus: String?
    ) {
        self.customerId = customerId
        self.customerNumber = customerNumber
        self.legalName = legalName
        self.email = email
        self.mobilePhoneNumber = mobilePhoneNumber
        self.dateOfBirth = dateOfBirth
        self.kycStatus = kycStatus
        self.employmentStatus = employmentStatus
        self.relationshipStatus = relationshipStatus
    }
}

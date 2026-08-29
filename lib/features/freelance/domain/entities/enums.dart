enum JobPostingStatus {
  draft,
  open,
  registrationClosed,
  inProgress,
  completed,
  cancelled,
}

enum JobApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
  completed,
  noShow,
}

enum PaymentType {
  perHour,
  perDay,
  perTask,
  fixed,
}

enum PaymentTiming {
  payOnCompletion,
  escrowUpfront,
}

enum CheckInMethod {
  qrCode,
  geoLocation,
  manualByEmployer,
  pinCode,
  any,
}

enum CheckInStatus {
  checkedIn,
  checkedOut,
  missed,
}

enum RaterRole {
  employer,
  worker,
}

enum ReputationRole {
  worker,
  employer,
}
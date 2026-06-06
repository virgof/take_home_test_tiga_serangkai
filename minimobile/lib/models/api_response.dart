class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.errors,
  });

  bool get isSuccess => status == 'success';

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'],
    );
  }
}
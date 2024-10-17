class ToDoDetailsResponse {
  final ToDoData data;
  final String? status;
  final String? remarks;

  ToDoDetailsResponse({
    required this.data,
    this.status,
    this.remarks,
  });

  factory ToDoDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ToDoDetailsResponse(
      data: ToDoData.fromJson(json['data']),
      status: json['status'],
      remarks: json['remarks'],
    );
  }
}

class ToDoData {
  final String? todoId;
  final String? content;
  final String? priority;
  final String? todoStatus;
  final String? creatorName;
  final String? handlingPersonName;
  final String? transferStatus;
  final String? transferPersonName;
  final String? transferPersonId;
  final String? transferApproveId;

  ToDoData({
    this.todoId,
    this.content,
    this.priority,
    this.todoStatus,
    this.creatorName,
    this.handlingPersonName,
    this.transferStatus,
    this.transferPersonName,
    this.transferPersonId,
    this.transferApproveId,
  });

  factory ToDoData.fromJson(Map<String, dynamic> json) {
    return ToDoData(
      todoId: json['todo_id'],
      content: json['content'],
      priority: json['priority'],
      todoStatus: json['todo_status'],
      creatorName: json['creator_name'],
      handlingPersonName: json['handling_person_name'],
      transferStatus: json['transfer_status'],
      transferPersonName: json['transfer_person_name'],
      transferPersonId: json['transfer_person_id'],
      transferApproveId: json['transfer_approve_id'],
    );
  }
}

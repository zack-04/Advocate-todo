// ignore_for_file: public_member_api_docs, sort_constructors_first
class ToDoResponse {
  String? selfCount;
  String? approvalCount;
  List<ToDoItem>? data;
  String? status;
  String? remarks;

  ToDoResponse({
    this.selfCount,
    this.approvalCount,
    this.data,
    this.status,
    this.remarks,
  });
  
  factory ToDoResponse.fromJson(Map<String, dynamic> json) {
    return ToDoResponse(
      selfCount: json['self_count'],
      approvalCount: json['approval_count'],
      data: json['data'] != null
          ? List<ToDoItem>.from(
              json['data'].map((item) => ToDoItem.fromJson(item)))
          : [],
      status: json['status'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'self_count': selfCount,
      'approval_count': approvalCount,
      'data': data?.map((item) => item.toJson()).toList(),
      'status': status,
      'remarks': remarks,
    };
  }

  @override
  String toString() {
    return 'ToDoResponse(selfCount: $selfCount, approvalCount: $approvalCount, data: $data, status: $status, remarks: $remarks)';
  }
}

class ToDoItem {
  String? todoId;
  String? content;
  String? priority;
  String? todoStatus;

  ToDoItem({
    this.todoId,
    this.content,
    this.priority,
    this.todoStatus,
  });

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    return ToDoItem(
      todoId: json['todo_id'],
      content: json['content'],
      priority: json['priority'],
      todoStatus: json['todo_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo_id': todoId,
      'content': content,
      'priority': priority,
      'todo_status': todoStatus,
    };
  }
}

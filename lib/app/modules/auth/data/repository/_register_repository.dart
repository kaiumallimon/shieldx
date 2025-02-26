import 'package:shieldx/app/modules/auth/data/services/_register_service.dart';

class RegisterRepository {
  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> data,
  }) async {
    var response = await RegisterService().register(data: data);

    print('response: $response');

    return response;
  }
}

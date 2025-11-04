class AuthStore {
  // TODO: ผูกกับระบบล็อกอินจริง (SharedPreferences / SecureStorage)
  // ตอนนี้ mock ไว้ก่อน
  Future<String?> getToken() async {
    // return 'eyJhbGciOi...'; // ถ้ามี token จริง
    return null; // ถ้า public endpoint ก็จะไม่แนบ Authorization
  }
}

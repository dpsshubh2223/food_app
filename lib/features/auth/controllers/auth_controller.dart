import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/update_user_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_selection_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service_interface.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLocationLoading = false;
  bool get isLocationLoading => _isLocationLoading;

  List<SignUpSelectionModel>? _zoneList;
  List<SignUpSelectionModel>? get zoneList => _zoneList;

  List<SignUpSelectionModel>? _areaList;
  List<SignUpSelectionModel>? get areaList => _areaList;

  List<SignUpSelectionModel>? _buildingList;
  List<SignUpSelectionModel>? get buildingList => _buildingList;

  List<SignUpSelectionModel>? _organizationList;
  List<SignUpSelectionModel>? get organizationList => _organizationList;

  SignUpSelectionModel? _selectedZone;
  SignUpSelectionModel? get selectedZone => _selectedZone;

  SignUpSelectionModel? _selectedArea;
  SignUpSelectionModel? get selectedArea => _selectedArea;

  SignUpSelectionModel? _selectedBuilding;
  SignUpSelectionModel? get selectedBuilding => _selectedBuilding;

  SignUpSelectionModel? _selectedOrganization;
  SignUpSelectionModel? get selectedOrganization => _selectedOrganization;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  bool _guestLoading = false;
  bool get guestLoading => _guestLoading;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isActiveRememberMeForOtp = false;
  bool get isActiveRememberMeForOtp => _isActiveRememberMeForOtp;

  bool _notification = true;
  bool get notification => _notification;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  var countryDialCode = "+880";

  bool _isOtpViewEnable = false;
  bool get isOtpViewEnable => _isOtpViewEnable;

  Future<ResponseModel> login(
      {required String emailOrPhone,
      required String password,
      required String loginType,
      required String fieldType,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(
        emailOrPhone: emailOrPhone,
        password: password,
        loginType: loginType,
        fieldType: fieldType,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> otpLogin(
      {required String phone,
      required String loginType,
      required String otp,
      required String verified,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(
        phone: phone,
        otp: otp,
        loginType: loginType,
        verified: verified,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void resetOtpView({bool isUpdate = true}) {
    _isOtpViewEnable = false;
    if (isUpdate) {
      update();
    }
  }

  Future<ResponseModel> updatePersonalInfo(
      {required String name,
      required String? phone,
      required String loginType,
      required String? email,
      required String? referCode,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(
        name: name,
        phone: phone,
        email: email,
        loginType: loginType,
        referCode: referCode,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void _getUserAndCartData(ResponseModel responseModel) {
    if (responseModel.isSuccess &&
        responseModel.authResponseModel != null &&
        responseModel.authResponseModel!.isPhoneVerified! &&
        responseModel.authResponseModel!.isEmailVerified! &&
        responseModel.authResponseModel!.isPersonalInfo! &&
        responseModel.authResponseModel!.isExistUser == null) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
    }
  }

  Future<ResponseModel> registration(SignUpBodyModel signUpModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await authServiceInterface.registration(signUpModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> getZoneList() async {
    _isLocationLoading = true;
    _selectedZone = null;
    _selectedArea = null;
    _selectedBuilding = null;
    _selectedOrganization = null;
    _areaList = null;
    _buildingList = null;
    _organizationList = null;
    update();
    _zoneList = await authServiceInterface.getZoneList();
    _isLocationLoading = false;
    update();
  }

  Future<void> getAreaListFromSelectedAddressZone() async {
    int? zoneId = AddressHelper.getAddressFromSharedPref()?.zoneId;
    _selectedZone = zoneId != null
        ? SignUpSelectionModel(id: zoneId, name: 'Zone $zoneId')
        : null;
    _selectedArea = null;
    _selectedBuilding = null;
    _selectedOrganization = null;
    _areaList = null;
    _buildingList = null;
    _organizationList = null;

    if (zoneId == null) {
      update();
      return;
    }

    _isLocationLoading = true;
    update();
    _zoneList ??= await authServiceInterface.getZoneList();
    if (_zoneList != null) {
      _selectedZone = _zoneList!.firstWhere(
        (zone) => zone.id == zoneId,
        orElse: () => SignUpSelectionModel(id: zoneId, name: 'Zone $zoneId'),
      );
    }
    _areaList = await authServiceInterface.getAreaList(zoneId);
    _isLocationLoading = false;
    update();
  }

  Future<void> initProfileLocationData({
    int? zoneId,
    int? areaId,
    int? buildingId,
    int? companyId,
    String? zoneName,
    String? areaName,
    String? buildingName,
    String? companyName,
  }) async {
    zoneId ??= AddressHelper.getAddressFromSharedPref()?.zoneId;
    _selectedZone = zoneId != null
        ? SignUpSelectionModel(id: zoneId, name: zoneName ?? 'Zone $zoneId')
        : null;
    _selectedArea = null;
    _selectedBuilding = null;
    _selectedOrganization = null;
    _areaList = null;
    _buildingList = null;
    _organizationList = null;

    if (zoneId == null) {
      update();
      return;
    }

    _isLocationLoading = true;
    update();

    _zoneList ??= await authServiceInterface.getZoneList();
    if (_zoneList != null) {
      _selectedZone = _findSelection(
        _zoneList!,
        zoneId,
        fallbackName: zoneName ?? 'Zone $zoneId',
      );
    }

    _areaList = await authServiceInterface.getAreaList(zoneId);
    if (areaId != null) {
      _selectedArea = _findSelection(_areaList, areaId, fallbackName: areaName);
      _buildingList = await authServiceInterface.getBuildingList(areaId);
    }

    if (buildingId != null) {
      _selectedBuilding =
          _findSelection(_buildingList, buildingId, fallbackName: buildingName);
      _organizationList =
          await authServiceInterface.getOrganizationList(buildingId);
    }

    if (companyId != null) {
      _selectedOrganization = _findSelection(_organizationList, companyId,
          fallbackName: companyName);
    }

    _isLocationLoading = false;
    update();
  }

  SignUpSelectionModel _findSelection(
    List<SignUpSelectionModel>? list,
    int id, {
    String? fallbackName,
  }) {
    return (list ?? []).firstWhere(
      (item) => item.id == id,
      orElse: () => SignUpSelectionModel(id: id, name: fallbackName ?? '$id'),
    );
  }

  Future<void> selectZone(SignUpSelectionModel zone) async {
    _selectedZone = zone;
    _selectedArea = null;
    _selectedBuilding = null;
    _selectedOrganization = null;
    _areaList = null;
    _buildingList = null;
    _organizationList = null;
    update();
    if (zone.id != null) {
      _areaList = await authServiceInterface.getAreaList(zone.id!);
      update();
    }
  }

  Future<void> selectArea(SignUpSelectionModel area) async {
    _selectedArea = area;
    _selectedBuilding = null;
    _selectedOrganization = null;
    _buildingList = null;
    _organizationList = null;
    update();
    if (area.id != null) {
      _buildingList = await authServiceInterface.getBuildingList(area.id!);
      update();
    }
  }

  Future<void> selectBuilding(SignUpSelectionModel building) async {
    _selectedBuilding = building;
    _selectedOrganization = null;
    _organizationList = null;
    update();
    if (building.id != null) {
      _organizationList =
          await authServiceInterface.getOrganizationList(building.id!);
      update();
    }
  }

  void selectOrganization(SignUpSelectionModel organization) {
    _selectedOrganization = organization;
    update();
  }

  void toggleIsNumberLogin({bool? value, bool willUpdate = true}) {
    if (value == null) {
      _isNumberLogin = !_isNumberLogin;
    } else {
      _isNumberLogin = value;
    }
    initCountryCode();
    if (willUpdate) {
      update();
    }
  }

  void enableOtpView({bool enable = false}) {
    _isOtpViewEnable = enable;
    update();
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode = countryCode ??
        CountryCode.fromCountryCode(
                Get.find<SplashController>().configModel!.country ?? "BD")
            .dialCode ??
        "+880";
  }

  void saveUserNumberAndPassword(
      {required String number,
      required String password,
      required String countryCode,
      required String otpPoneNumber}) {
    authServiceInterface.saveUserNumberAndPassword(
        number: number,
        password: password,
        countryCode: countryCode,
        otpPoneNumber: otpPoneNumber);
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  String getUserOtpPhoneNumber() {
    return authServiceInterface.getUserOtpPhoneNumber();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleRememberMeForOtp() {
    _isActiveRememberMeForOtp = !_isActiveRememberMeForOtp;
    update();
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> loginWithSocialMedia(
      SocialLogInBodyModel socialLogInBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await authServiceInterface.loginWithSocialMedia(socialLogInBody,
            isCustomerVerificationOn: Get.find<SplashController>()
                .configModel!
                .customerVerification!);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  String getGuestId() {
    return authServiceInterface.getGuestId();
  }

  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn() &&
        !authServiceInterface.isLoggedIn();
  }

  Future<void> socialLogout() async {
    await authServiceInterface.socialLogout();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<void> saveGuestNumber(String number) async {
    authServiceInterface.saveGuestNumber(number);
  }

  String getGuestNumber() {
    return authServiceInterface.getGuestNumber();
  }

  Future<void> firebaseVerifyPhoneNumber(
      String phoneNumber, String? token, String loginType,
      {bool fromSignUp = true,
      bool canRoute = true,
      UpdateUserModel? updateUserModel}) async {
    _isLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if (e.code == 'invalid-phone-number') {
          showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
        } else {
          showCustomSnackBar(e.message?.replaceAll('_', ' '));
        }
      },
      codeSent: (String vId, int? resendToken) {
        _isLoading = false;
        update();
        if (updateUserModel != null) {
          updateUserModel.sessionInfo = vId;
        }

        if (canRoute) {
          if (ResponsiveHelper.isDesktop(Get.context)) {
            Get.back();
            Get.dialog(VerificationScreen(
              number: phoneNumber,
              email: null,
              token: token,
              fromSignUp: fromSignUp,
              fromForgetPassword: !fromSignUp,
              loginType: loginType,
              password: '',
              firebaseSession: vId,
              userModel: updateUserModel,
            ));
          } else {
            Get.toNamed(RouteHelper.getVerificationRoute(
              phoneNumber,
              '',
              token,
              fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword,
              '',
              loginType,
              session: vId,
              updateUserModel: updateUserModel,
            ));
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}

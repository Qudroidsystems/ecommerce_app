import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../../../utils/validators/validation.dart';
import '../models/address_model.dart';
import '../screens/address/add_new_address.dart';
import '../screens/address/widgets/single_address_widget.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final name = TextEditingController();
  final street = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final zipCode = TextEditingController();
  final phoneNo = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  RxBool refreshData = true.obs;
  final addressRepository = Get.put(AddressRepository());
  final Rx<bool> billingSameAsShipping = true.obs;
  final Rx<AddressModel> selectedAddress = AddressModel.empty().obs;
  final Rx<AddressModel> selectedBillingAddress = AddressModel.empty().obs;

  /// Fetch all user-specific addresses
  Future<List<AddressModel>> allUserAddresses() async {
    try {
      final addresses = await addressRepository.fetchUserAddresses();
      selectedAddress.value = addresses.firstWhere(
            (element) => element.selectedAddress,
        orElse: () => AddressModel.empty(),
      );
      return addresses;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Address not found', message: e.toString());
      return [];
    }
  }

  /// Select an Address
  Future<void> selectAddress({required AddressModel newSelectedAddress, bool isBillingAddress = false}) async {
    try {
      if (!isBillingAddress) {
        if (selectedAddress.value.id.isNotEmpty) {
          await addressRepository.updateSelectedField(
            addressId: selectedAddress.value.id,
            selected: false,
          );
        }

        selectedAddress.value = newSelectedAddress.copyWith(selectedAddress: true);

        await addressRepository.updateSelectedField(
          addressId: newSelectedAddress.id,
          selected: true,
        );
      } else {
        selectedBillingAddress.value = newSelectedAddress;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error in Selection', message: e.toString());
    }
  }

  /// Add New Address
  Future<void> addNewAddress() async {
    try {
      TFullScreenLoader.openLoadingDialog('Storing Address...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }
      if (!addressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final phoneError = TValidator.validatePhoneNumber(phoneNo.text.trim());
      if (phoneError != null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'Invalid Phone Number', message: phoneError);
        return;
      }
      final zipError = TValidator.validateZipCode(zipCode.text.trim());
      if (zipError != null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'Invalid Zip Code', message: zipError);
        return;
      }

      final address = AddressModel(
        id: '',
        name: name.text.trim(),
        userId: AuthenticationRepository.instance.getUserID,
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        zipCode: zipCode.text.trim(),
        country: country.text.trim(),
        phoneNo: phoneNo.text.trim(),
        selectedAddress: true,
      );

      final id = await addressRepository.addAddress(address);
      final updatedAddress = address.copyWith(id: id);

      await selectAddress(newSelectedAddress: updatedAddress);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Congratulations', message: 'Your address has been saved successfully.');

      refreshData.toggle();
      resetFormFields();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Show address selection popup
  Future<dynamic> selectNewAddressPopup({required BuildContext context, bool isBillingAddress = false}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TSectionHeading(title: 'Select Address', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),
              FutureBuilder(
                future: addressRepository.fetchUserAddresses(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No addresses found'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => TSingleAddress(
                      address: snapshot.data![index],
                      isBillingAddress: isBillingAddress,
                      onTap: () async {
                        await selectAddress(newSelectedAddress: snapshot.data![index], isBillingAddress: isBillingAddress);
                        Get.back();
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: TSizes.defaultSpace),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const AddNewAddressScreen()),
                  child: const Text('Add new address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Update existing address
  Future<void> updateAddress(AddressModel oldAddress) async {
    try {
      TFullScreenLoader.openLoadingDialog('Updating your Address...', TImages.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.customToast(message: 'No Internet Connection');
        return;
      }

      if (!addressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final phoneError = TValidator.validatePhoneNumber(phoneNo.text.trim());
      if (phoneError != null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'Invalid Phone Number', message: phoneError);
        return;
      }
      final zipError = TValidator.validateZipCode(zipCode.text.trim());
      if (zipError != null) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'Invalid Zip Code', message: zipError);
        return;
      }

      final address = AddressModel(
        id: oldAddress.id,
        userId: AuthenticationRepository.instance.getUserID,
        name: name.text.trim(),
        phoneNo: phoneNo.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        zipCode: zipCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: oldAddress.selectedAddress,
      );

      await addressRepository.updateAddress(address);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Success', message: 'Your address has been updated successfully.');

      refreshData.toggle();
      resetFormFields();
      Get.back();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error Updating Address', message: e.toString());
    }
  }

  /// Initialize form fields for updating an address
  void initUpdateAddressValues(AddressModel address) {
    name.text = address.name;
    phoneNo.text = address.phoneNo;
    street.text = address.street;
    zipCode.text = address.zipCode;
    city.text = address.city;
    state.text = address.state;
    country.text = address.country;
  }

  /// Reset form fields
  void resetFormFields() {
    name.clear();
    street.clear();
    city.clear();
    state.clear();
    country.clear();
    zipCode.clear();
    phoneNo.clear();
    addressFormKey.currentState?.reset();
  }
}
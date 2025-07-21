import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/texts/section_heading.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/cloud_helper_functions.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/address_model.dart';
import '../screens/address/add_new_address.dart';
import '../screens/address/widgets/single_address_widget.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final name = TextEditingController();
  final phoneNumber = TextEditingController();
  final street = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
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

  /// Select an address (shipping or billing)
  Future<void> selectAddress({required AddressModel newSelectedAddress, bool isBillingAddress = false}) async {
    try {
      if (!isBillingAddress) {
        if (selectedAddress.value.id.isNotEmpty) {
          await addressRepository.updateSelectedField(
            AuthenticationRepository.instance.getUserID,
            selectedAddress.value.id,
            false,
          );
        }
        newSelectedAddress = newSelectedAddress.copyWith(selectedAddress: true);
        selectedAddress.value = newSelectedAddress;
        await addressRepository.updateSelectedField(
          AuthenticationRepository.instance.getUserID,
          selectedAddress.value.id,
          true,
        );
      } else {
        selectedBillingAddress.value = newSelectedAddress;
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error in Selection', message: e.toString());
    }
  }

  /// Add new address
  Future<void> addNewAddresses() async {
    try {
      TFullScreenLoader.openLoadingDialog('Storing Address...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!addressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final address = AddressModel(
        id: '',
        userId: AuthenticationRepository.instance.getUserID,
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: true,
      );
      final id = await addressRepository.addAddress(address, AuthenticationRepository.instance.getUserID);
      address.id = id;
      await selectAddress(newSelectedAddress: address);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Congratulations', message: 'Your address has been saved successfully.');
      refreshData.toggle();
      resetFormFields();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Address not found', message: e.toString());
    }
  }

  /// Show addresses in a ModalBottomSheet at checkout
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
                future: allUserAddresses(),
                builder: (_, snapshot) => TCloudHelperFunctions.checkMultiRecordState(
                  snapshot: snapshot,
                  loader: const Center(child: CircularProgressIndicator()),
                  error: Center(child: Text('Error: ${snapshot.error}')),
                  nothingFound: const Center(child: Text('No addresses found')),
                ) ?? ListView.builder(
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
                ),
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

  /// Initialize values for updating an address
  void initUpdateAddressValues(AddressModel address) {
    name.text = address.name;
    phoneNumber.text = address.phoneNumber;
    street.text = address.street;
    postalCode.text = address.postalCode;
    city.text = address.city;
    state.text = address.state;
    country.text = address.country;
  }

  /// Update an existing address
  Future<void> updateAddress(AddressModel oldAddress) async {
    try {
      TFullScreenLoader.openLoadingDialog('Updating your Address...', TImages.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!addressFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      final address = AddressModel(
        id: oldAddress.id,
        userId: AuthenticationRepository.instance.getUserID,
        name: name.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        street: street.text.trim(),
        city: city.text.trim(),
        state: state.text.trim(),
        postalCode: postalCode.text.trim(),
        country: country.text.trim(),
        selectedAddress: oldAddress.selectedAddress,
      );
      await addressRepository.updateAddress(address, AuthenticationRepository.instance.getUserID);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Congratulations', message: 'Your address has been updated successfully.');
      refreshData.toggle();
      resetFormFields();
      Navigator.of(Get.context!).pop();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error Updating Address', message: e.toString());
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      TFullScreenLoader.openLoadingDialog('Deleting Address...', TImages.docerAnimation);
      final userId = AuthenticationRepository.instance.getUserID;
      await addressRepository.deleteAddress(userId, addressId);
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(title: 'Success', message: 'Address deleted successfully.');
      refreshData.toggle();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Error Deleting Address', message: e.toString());
    }
  }

  /// Reset form fields
  void resetFormFields() {
    name.clear();
    phoneNumber.clear();
    street.clear();
    postalCode.clear();
    city.clear();
    state.clear();
    country.clear();
    addressFormKey.currentState?.reset();
  }
}
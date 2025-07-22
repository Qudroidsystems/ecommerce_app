import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/t_circular_image.dart';

class TUserProfileTile extends StatelessWidget {
  TUserProfileTile({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;
  final controller = UserController.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      final isNetworkImage = user.profileImage != null && user.profileImage!.isNotEmpty;
      final image = isNetworkImage ? user.profileImage! : TImages.user;
      final displayName = user.fullName.isNotEmpty ? user.fullName : 'No Name';
      final displayEmail = user.email.isNotEmpty ? user.email : 'No Email';
      return ListTile(
        leading: TCircularImage(
          padding: 0,
          image: image,
          width: 50,
          height: 50,
          isNetworkImage: isNetworkImage,
        ),
        title: Text(
          displayName,
          style: Theme.of(context).textTheme.headlineSmall!.apply(color: TColors.white),
        ),
        subtitle: Text(
          displayEmail,
          style: Theme.of(context).textTheme.bodyMedium!.apply(color: TColors.white),
        ),
        trailing: IconButton(
          onPressed: onPressed,
          icon: const Icon(Iconsax.edit, color: TColors.white),
        ),
      );
    });
  }
}
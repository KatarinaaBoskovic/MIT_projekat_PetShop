import 'package:petshop/view/shipping_address/models/address.dart';

class AddressRepository {
  List<Address> getAddresses() {
    return const [
      Address(
        id: '1',
        label: 'Home',
        fullAddress: '123 Main Street, Apt 48',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        isDefault: true,
        type: AddressType.home,
      ),
      Address(
        id: '2',
        label: 'Office',
        fullAddress: '324 Business Ave, Suite 200',
        city: 'New York',
        state: 'NY',
        zipCode: '10002',
        type: AddressType.office,
      ),
      
    ];
  }
  Address? getDefaultAddress(){
    return getAddresses().firstWhere(
      (address)=>address.isDefault,
      orElse: ()=>getAddresses().first,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/services/blood_request_model.dart';
import '../../../../shared/services/local_blood_request_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final postBloodRequestProvider = StateNotifierProvider<PostBloodRequestNotifier, PostBloodRequestState>((ref) {
  return PostBloodRequestNotifier(ref);
});

class PostBloodRequestState {
  final bool isLoading;
  final String? error;

  const PostBloodRequestState({this.isLoading = false, this.error});

  PostBloodRequestState copyWith({bool? isLoading, String? error}) {
    return PostBloodRequestState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PostBloodRequestNotifier extends StateNotifier<PostBloodRequestState> {
  final Ref _ref;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  PostBloodRequestNotifier(this._ref) : super(const PostBloodRequestState());

  Future<void> submitRequest({
    required String bloodType,
    required int units,
    required String location,
    required String urgency,
    required String hospitalName,
    required String contactPhone,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final uid = await _secureStorage.read(key: 'user_id');
      if (uid == null) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      // Use local blood request service instead of Firestore
      final requestService = _ref.read(localBloodRequestServiceProvider);
      await requestService.createRequest(
        receiverId: uid,
        receiverName: 'User',
        bloodType: bloodType,
        unitsNeeded: units,
        location: location,
        urgency: urgency,
        hospitalName: hospitalName,
        contactPhone: contactPhone,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class PostBloodRequestScreen extends ConsumerStatefulWidget {
  const PostBloodRequestScreen({super.key});

  @override
  ConsumerState<PostBloodRequestScreen> createState() => _PostBloodRequestScreenState();
}

class _PostBloodRequestScreenState extends ConsumerState<PostBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedBloodType;
  int _units = 1;
  String _urgency = 'normal';

  @override
  void dispose() {
    _locationController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select blood type')),
      );
      return;
    }

    await ref.read(postBloodRequestProvider.notifier).submitRequest(
          bloodType: _selectedBloodType!,
          units: _units,
          location: _locationController.text,
          urgency: _urgency,
          hospitalName: _hospitalController.text,
          contactPhone: _phoneController.text,
        );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postBloodRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Blood Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Blood Type Required', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: BloodType.all.map((type) {
                    final isSelected = _selectedBloodType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedBloodType = type),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Units Needed', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    IconButton(
                      onPressed: _units > 1 ? () => setState(() => _units--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_units', style: Theme.of(context).textTheme.headlineSmall),
                    IconButton(
                      onPressed: _units < 10 ? () => setState(() => _units++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Urgency', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'normal', label: Text('Normal')),
                    ButtonSegment(value: 'urgent', label: Text('Urgent')),
                  ],
                  selected: {_urgency},
                  onSelectionChanged: (value) => setState(() => _urgency = value.first),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'City/Area',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _hospitalController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name',
                    hintText: 'Enter hospital name',
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone',
                    hintText: '+91 9876543210',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:swiftrun/common/styles/colors.dart';
import 'package:swiftrun/common/styles/style.dart';
import 'package:swiftrun/common/utils/utils.dart';
import 'package:swiftrun/common/widgets/customArrowBack.dart';
import 'package:swiftrun/features/profile/controller.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final profileController = Get.put(ProfileController());
  final TextEditingController _searchController = TextEditingController();
  List faqList = [];
  List filteredFaqList = [];
  String _searchQuery = '';

  @override
  void initState() {
    fetchFaqs();
    super.initState();
  }

  Future<void> fetchFaqs() async {
    try {
      faqList = await profileController.getFaq();
      print("FAQ Data received: $faqList");
      print("FAQ List length: ${faqList.length}");
      if (faqList.isNotEmpty) {
        print("First FAQ item: ${faqList.first}");
        print("First FAQ keys: ${faqList.first.keys.toList()}");
      }
      
      // Process the FAQ data to ensure we have the right structure
      List processedFaqList = [];
      for (var faq in faqList) {
        print("Processing FAQ: $faq");
        // Check if the FAQ has the expected structure
        if (faq is Map<String, dynamic>) {
          // If it has question and answer directly
          if (faq.containsKey('question') && faq.containsKey('answer')) {
            processedFaqList.add(faq);
          }
          // If it has subject and content (old structure)
          else if (faq.containsKey('subject') && faq.containsKey('content')) {
            processedFaqList.add({
              'question': faq['subject'],
              'answer': faq['content'],
            });
          }
          // If it's nested under document ID
          else {
            // Look for nested FAQ data
            for (var key in faq.keys) {
              if (faq[key] is Map && faq[key].containsKey('question') && faq[key].containsKey('answer')) {
                processedFaqList.add(faq[key]);
                break;
              }
            }
          }
        }
      }
      
      print("Processed FAQ List: $processedFaqList");
      
      // If no FAQs found, add some sample data for testing
      if (processedFaqList.isEmpty) {
        print("No FAQs found, adding sample data");
        processedFaqList = [
          {
            'question': 'How can I reach SwiftRun on whatsapp?',
            'answer': 'You can reach us on 07000000000',
          },
          {
            'question': 'How do I book a delivery?',
            'answer': 'Tap the "Book Delivery" button and follow the steps to complete your request.',
          },
          {
            'question': 'How can I track my delivery?',
            'answer': 'Go to the tracking section to see real-time updates of your delivery.',
          },
        ];
      }
      
      faqList = processedFaqList;
      filteredFaqList = List.from(faqList);
      setState(() {});
    } catch (e) {
      print("Error fetching FAQs: $e");
      faqList = [];
      filteredFaqList = [];
      setState(() {});
    }
  }

  void _filterFaqs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredFaqList = List.from(faqList);
      } else {
        filteredFaqList = faqList.where((faq) {
          final question = (faq['question'] ?? faq['subject'] ?? '').toString().toLowerCase();
          final answer = (faq['answer'] ?? faq['content'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return question.contains(searchQuery) || answer.contains(searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: mainPaddingWidth, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CustomArrowBack(),
                  20.horizontalSpace,
                  Expanded(
                    child: Text(
                      "Frequently Asked Questions",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(mainPaddingWidth),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterFaqs,
                        decoration: InputDecoration(
                          hintText: "Search FAQs...",
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 20.sp,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterFaqs('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        ),
                      ),
                    ),

                    20.verticalSpace,

                    // FAQ List
                    Expanded(
                      child: faqList.isEmpty
                          ? _buildLoadingState()
                          : filteredFaqList.isEmpty
                              ? _buildNoResultsState()
                              : _buildFaqList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              strokeWidth: 3,
            ),
          ),
          20.verticalSpace,
          Text(
            "Loading FAQs...",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.search_off,
              size: 48.sp,
              color: Colors.grey[400],
            ),
          ),
          20.verticalSpace,
          Text(
            "No FAQs found",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          8.verticalSpace,
          Text(
            "Try searching with different keywords",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    return ListView.builder(
      itemCount: filteredFaqList.length,
      itemBuilder: (context, index) {
        final faqData = filteredFaqList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              childrenPadding: EdgeInsets.only(bottom: 16.h),
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: AppColor.primaryColor,
                  size: 20.sp,
                ),
              ),
              title: Text(
                faqData['question'] ?? faqData['subject'] ?? 'No question available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    faqData['answer'] ?? faqData['content'] ?? 'No answer available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
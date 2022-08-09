import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:watchbook4/controller/login_controller.dart';

class agreement_view extends GetView<LoginController>{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                width:
                MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .width,
                //인풋박스 터치시 키보드 안나오는 에러 수정(원인 : 미디어쿼리)
                height:
                MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                    .size
                    .height,
                color: Colors.white,
                child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                        width: MediaQueryData.fromWindow(
                            WidgetsBinding.instance!.window)
                            .size
                            .width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '개인정보 수집 및 이용 안내 동의',
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Color.fromARGB(255, 0, 104, 166)),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: const Color.fromARGB(255, 0, 104, 166),
                              width: 1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 50),
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration:const BoxDecoration(
                          border:  Border(
                              top: BorderSide(
                                color: Color.fromARGB(
                                    255, 206, 206, 206),
                              ),
                              bottom: BorderSide(
                                color: Color.fromARGB(
                                    255, 206, 206, 206),
                              )
                          ),
                        ),
                        height: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                            .size
                            .height - 350,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text('제25조(개인정보보호)\n\n\n① "회사"는 제7조 제2항의 신청서기재사항 이외에 "이용자"의 콘텐츠이용에 필요한 최소한의 정보를 수집할 수 있습니다.\n이를 위해 "회사"가 문의한 사항에 관해 "이용자"는 진실한 내용을 성실하게 고지하여야 합니다.\n② "회사"가 "이용자"의 개인 식별이 가능한 "개인정보"를 수집하는 때에는 당해 "이용자"의 동의를 받습니다.\n③ "회사"는 "이용자"가 이용신청 등에서 제공한 정보와 제1항에 의하여 수집한 정보를 당해 "이용자"의 동의 없이 목적 외로 이용하거나 제3자에게 제공할 수 없으며, 이를 위반한 경우에 모든 책임은 "회사"가 집니다. 다만, 다음의 경우에는 예외로 합니다.\n\n1. 통계작성, 학술연구 또는 시장조사를 위하여 필요한 경우로서 특정 개인을 식별할 수 없는 형태로 제공하는 경우\n\n2. "콘텐츠" 제공에 따른 요금정산을 위하여 필요한 경우\n\n3. 도용방지를 위하여 본인확인에 필요한 경우\n\n4. 약관의 규정 또는 법령에 의하여 필요한 불가피한 사유가 있는 경우\n④ "회사"가 제2항과 제3항에 의해 "이용자"의 동의를 받아야 하는 경우에는 "개인정보"관리책임자의 신원(소속, 성명 및 전화번호 기타 연락처), 정보의 수집목적 및 이용목적, 제3자에 대한 정보제공관련사항(제공받는 자, 제공목적 및 제공할 정보의 내용)등에 관하여 정보통신망이용촉진 및 정보보호 등에 관한 법률 제22조 제2항이 규정한 사항을 명시하고 고지하여야 합니다.\n⑤ "이용자"는 언제든지 제3항의 동의를 임의로 철회할 수 있습니다.\n⑥ "이용자"는 언제든지 "회사"가 가지고 있는 자신의 "개인정보"에 대해 열람 및 오류의 정정을 요구할 수 있으며, "회사"는 이에 대해 지체 없이 필요한 조치를 취할 의무를 집니다. "이용자"가 오류의 정정을 요구한 경우에는 "회사"는 그 오류를 정정할 때까지 당해 "개인정보"를 이용하지 않습니다.\n⑦ "회사"는 개인정보보호를 위하여 관리자를 한정하여 그 수를 최소화하며, 신용카드, 은행계좌 등을 포함한 "이용자"의 "개인정보"의 분실, 도난, 유출, 변조 등으로 인한 "이용자"의 손해에 대하여 책임을 집니다.\n⑧ "회사" 또는 그로부터 "개인정보"를 제공받은 자는 "이용자"가 동의한 범위 내에서 "개인정보"를 사용할 수 있으며, 목적이 달성된 경우에는 당해 "개인정보"를 지체 없이 파기합니다.\n⑨ "회사"는 정보통신망이용촉진 및 정보보호에 관한 법률 등 관계 법령이 정하는 바에 따라 "이용자"의 "개인정보"를 보호하기 위해 노력합니다. "개인정보"의 보호 및 사용에 대해서는 관련법령 및 "회사"의 개인정보보호정책이 적용됩니다.'
                                ,style:
                                TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(
                                      255, 91, 91, 91),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      Container(
                        height: 106,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  "동의",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                color: const Color.fromARGB(
                                    255, 0, 104, 166),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 0, 104, 166)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text(
                                  "닫기",
                                  style: TextStyle(
                                      fontSize: 16, color: Color.fromARGB(
                                      255, 0, 104, 166)),
                                ),
                                color: const Color.fromARGB(
                                    255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 0, 104, 166)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ]
                )
            )
        )
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return true;
  }
  
}
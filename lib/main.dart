import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'dart:math';
import 'package:keyboard_actions/keyboard_actions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF448AFF),
        accentColor: const Color(0xFF448AFF),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // FocusNode
  final FocusNode _currentBalanceFocusNode = FocusNode(); // 入力項目：元本（万円）
  final FocusNode _monthlyAdditionFocusNode = FocusNode(); // 入力項目：積立金額（万円）
  final FocusNode _interestRateYearFocusNode = FocusNode(); // 入力項目：年利（％）
  final FocusNode _periodYearFocusNode = FocusNode(); // 入力項目：投資期間（年）

  // 入力項目のコントローラ
  var _controllerCurrentBalance = TextEditingController(); // 入力項目：元本（万円）
  var _controllerMonthlyAddition = TextEditingController(); // 入力項目：積立金額（万円）
  var _controllerInterestRateYear = TextEditingController(); // 入力項目：年利（％）
  var _controllerPeriodYear = TextEditingController(); // 入力項目：投資期間（年）

  // onChanged時、コントローラ => Decimalで受けるインスタンス
  Decimal _inputCurrentBalance; // 入力項目：元本（万円）
  Decimal _inputMonthlyAddition; // 入力項目：積立金額（万円）
  Decimal _inputInterestRateYear; // 入力項目：年利（％）
  int _inputPeriodYear; // 入力項目：投資期間（年）

  Decimal _inputInterestRateYearActualNumber; // 年利（実数）
  Decimal _inputInterestRateMonthActualNumber; // 月利（実数）

  // 積立タイプ
  String _additionalType; // Xヶ月。文字列。1,2,6,12の４パターン

  // 試験的に使ってみる変数たち
  String _outputFinalAsshole; // 投資総額
  String _outputFinalSimpleBalance; //単利金額
  String _outputFinalCompoundBalance; // 複利金額
  String _outputGrowthRate; //増加率

  // KeyboardActionsConfig
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[100],
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _currentBalanceFocusNode,
        ),
        KeyboardAction(
          focusNode: _monthlyAdditionFocusNode,
        ),
        KeyboardAction(
          focusNode: _interestRateYearFocusNode,
        ),
        KeyboardAction(
          focusNode: _periodYearFocusNode,
        ),
      ],
    );
  }

  // 項目設定メソッド
  void setDecimalCurrentBalance(String value) {
    this.setState(() {
      _inputCurrentBalance = Decimal.parse(_controllerCurrentBalance.text);
    });
  }

  void setDecimalMonthlyAddition(String value) {
    this.setState(() {
      _inputMonthlyAddition = Decimal.parse(_controllerMonthlyAddition.text);
    });
  }

  void setDecimalInterestRateYear(String value) {
    this.setState(() {
      _inputInterestRateYear = Decimal.parse(_controllerInterestRateYear.text);
      _inputInterestRateYearActualNumber =
          _inputInterestRateYear / Decimal.fromInt(100) + Decimal.fromInt(1);
      _inputInterestRateMonthActualNumber = Decimal.parse(((pow(
                          _inputInterestRateYearActualNumber.toDouble(),
                          double.parse('0.0833333')) *
                      10000)
                  .round() /
              10000)
          .toString());
    });
  }

  void setDecimalPeriodYear(String value) {
    this.setState(() {
      _inputPeriodYear = int.parse(_controllerPeriodYear.text);
    });
    print(_inputPeriodYear);
  }

  // GOボタン押下処理
  void buttonPressed() {
    //入力チェック
    if ((_controllerCurrentBalance.text == '') ||
        (_controllerInterestRateYear.text == '') ||
        (_controllerPeriodYear.text == '')) {
      print('入力エラー');
      final snackBarInputError = SnackBar(
        content: Text('条件を入れてね！'),
        action: SnackBarAction(
          label: 'すみません（汗）',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      _scaffoldKey.currentState.showSnackBar(snackBarInputError);
    } else {
      // メイン処理コール
      calcValueMain();
    }
  }

  // メイン処理
  void calcValueMain() {
    // 積立金額埋め
    if (_controllerMonthlyAddition.text == '') {
      this.setState(() {
        _inputMonthlyAddition = Decimal.parse('0');
      });
    }

    print(_inputInterestRateYear);
    print(_inputInterestRateYearActualNumber);
    print(_inputInterestRateMonthActualNumber);

    // 積立タイプごとに計算分岐
    switch (_additionalType) {
      case '1':
        {
          calcValueStandard(
            _inputCurrentBalance,
            _inputMonthlyAddition,
            _inputInterestRateMonthActualNumber,
            _inputPeriodYear,
            _inputInterestRateYear,
          );
          this.showMessageCalcComplete();
        }
        break;
      case '2':
        {
          calcValueTwiceMonth(
            _inputCurrentBalance,
            _inputMonthlyAddition,
            _inputInterestRateMonthActualNumber,
            _inputPeriodYear,
            _inputInterestRateYear,
          );
          this.showMessageCalcComplete();
        }
        break;
      case '6':
        {
          calcValueHalfYear(
            _inputCurrentBalance,
            _inputMonthlyAddition,
            _inputInterestRateMonthActualNumber,
            _inputPeriodYear,
            _inputInterestRateYear,
          );
          this.showMessageCalcComplete();
        }
        break;
      case '12':
        {
          calcValueOneYear(
            _inputCurrentBalance,
            _inputMonthlyAddition,
            _inputInterestRateMonthActualNumber,
            _inputPeriodYear,
            _inputInterestRateYear,
          );
          this.showMessageCalcComplete();
        }
        break;
      default:
        {
          print('積立タイプ例外エラー');
          final snackBarErrorAdditionType = SnackBar(
            content: Text('積立タイプを選択してください'),
            action: SnackBarAction(
              label: 'すみません',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          _scaffoldKey.currentState.showSnackBar(snackBarErrorAdditionType);
        }
        break;
    }
  }

  void showMessageCalcComplete() {
    final snackBarComplete = SnackBar(
      content: Text('計算されました！'),
      action: SnackBarAction(
        label: 'りょ',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    _scaffoldKey.currentState.showSnackBar(snackBarComplete);
  }

  // 積立タイプ１ヶ月
  void calcValueStandard(
    Decimal currentBalance,
    Decimal monthlyAddition,
    Decimal interestRate,
    int periodYear,
    Decimal interestRateYear,
  ) {
    // 配列準備
    List<Decimal> assholeFinalBalance = new List(); // タンス預金（年）
    List<Decimal> simpleInterestBalance = new List(); // 単利計算（年）
    List<Decimal> compoundInterestBalance = new List(); // 複利計算（年）
    List<Decimal> compoundCalculationBalance = new List(); // 複利計算（月）

    // INITIALIZE
    assholeFinalBalance.add(currentBalance);
    simpleInterestBalance.add(currentBalance);
    compoundInterestBalance.add(currentBalance);
    compoundCalculationBalance.add(currentBalance);

    int count = 1; // 月カウント
    int countYear = 1; // 年カウント

    Decimal compoundMonthValue; // 毎月の金額
    Decimal compoundYearValue; // 毎年の金額

    /*
    * 計算ループ　
    * 毎月の金額を計算（小数第２位までで四捨五入）し、
    * １年の節目で年額を計算する。
    */
    while (count < periodYear * 12 + 1) {
      compoundMonthValue =
          ((((compoundCalculationBalance[count - 1] + monthlyAddition) *
                          interestRate) *
                      Decimal.fromInt(100))
                  .round() /
              Decimal.fromInt(100));
      compoundCalculationBalance.add(compoundMonthValue);
      if (count % 12 == 0) {
        // タンス預金
        assholeFinalBalance.add(currentBalance +
            ((monthlyAddition *
                Decimal.fromInt(12) *
                Decimal.fromInt(countYear))));
        // 単利計算
        simpleInterestBalance.add(((currentBalance +
                        (monthlyAddition *
                            Decimal.fromInt(12) *
                            Decimal.fromInt(countYear)) +
                        (currentBalance *
                            interestRateYear /
                            Decimal.fromInt(100) *
                            Decimal.fromInt(countYear))) *
                    Decimal.fromInt(10))
                .round() /
            Decimal.fromInt(10));
        // 複利計算
        compoundYearValue = (compoundMonthValue * Decimal.fromInt(10)).round() /
            Decimal.fromInt(10);
        compoundInterestBalance.add(compoundYearValue);

        print('Asshole=${assholeFinalBalance[countYear]}');
        print('Tanri=${simpleInterestBalance[countYear]}');
        print('Fukuri=${compoundInterestBalance[countYear]}');

        countYear++;
      }
      count++;
    }

    // 画面表示をset
    setState(() {
      _outputFinalAsshole = assholeFinalBalance[countYear - 1].toString();
      _outputFinalSimpleBalance =
          simpleInterestBalance[countYear - 1].toString();
      _outputFinalCompoundBalance =
          compoundInterestBalance[countYear - 1].toString();
      _outputGrowthRate = ((compoundInterestBalance[countYear - 1].toDouble() /
                      assholeFinalBalance[countYear - 1].toDouble() *
                      100)
                  .round() -
              100)
          .toString();
    });
  }

  // 積立タイプ２ヶ月
  void calcValueTwiceMonth(
    Decimal currentBalance,
    Decimal monthlyAddition,
    Decimal interestRate,
    int periodYear,
    Decimal interestRateYear,
  ) {
    // 配列準備
    List<Decimal> assholeFinalBalance = new List(); // タンス預金（年）
    List<Decimal> simpleInterestBalance = new List(); // 単利計算（年）
    List<Decimal> compoundInterestBalance = new List(); // 複利計算（年）
    List<Decimal> compoundCalculationBalance = new List(); // 複利計算（月）

    //INITIALIZE
    assholeFinalBalance.add(currentBalance);
    simpleInterestBalance.add(currentBalance);
    compoundInterestBalance.add(currentBalance);
    compoundCalculationBalance.add(currentBalance);

    int count = 1; //月カウント
    int countYear = 1; //年カウント

    Decimal compoundMonthValue; // 毎月の金額
    Decimal compoundYearValue; // 毎年の金額

    /*
    * 計算ループ　
    * 毎月の金額を計算（小数第２位までで四捨五入）し、
    * １年の節目で年額を計算する。
    */
    while (count < periodYear * 12 + 1) {
      if (count % 2 == 0) {
        compoundMonthValue =
            ((((compoundCalculationBalance[count - 1] + monthlyAddition) *
                            interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);
      } else {
        compoundMonthValue =
            (((compoundCalculationBalance[count - 1] * interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);
      }
      if (count % 12 == 0) {
        //タンス預金
        assholeFinalBalance.add(currentBalance +
            ((monthlyAddition *
                Decimal.fromInt(6) *
                Decimal.fromInt(countYear))));
        //単利計算
        simpleInterestBalance.add(((currentBalance +
                        (monthlyAddition *
                            Decimal.fromInt(6) *
                            Decimal.fromInt(countYear)) +
                        (currentBalance *
                            interestRateYear /
                            Decimal.fromInt(100) *
                            Decimal.fromInt(countYear))) *
                    Decimal.fromInt(10))
                .round() /
            Decimal.fromInt(10));
        //複利計算
        compoundYearValue = (compoundMonthValue * Decimal.fromInt(10)).round() /
            Decimal.fromInt(10);
        compoundInterestBalance.add(compoundYearValue);

        print('Asshole=${assholeFinalBalance[countYear]}');
        print('Tanri=${simpleInterestBalance[countYear]}');
        print('Fukuri=${compoundInterestBalance[countYear]}');

        countYear++;
      }
      count++;
    }

    //画面表示をset
    setState(() {
      _outputFinalAsshole = assholeFinalBalance[countYear - 1].toString();
      _outputFinalSimpleBalance =
          simpleInterestBalance[countYear - 1].toString();
      _outputFinalCompoundBalance =
          compoundInterestBalance[countYear - 1].toString();
      _outputGrowthRate = ((compoundInterestBalance[countYear - 1].toDouble() /
                  assholeFinalBalance[countYear - 1].toDouble())
              .round())
          .toString();
    });
  }

  void calcValueHalfYear(
    Decimal currentBalance,
    Decimal monthlyAddition,
    Decimal interestRate,
    int periodYear,
    Decimal interestRateYear,
  ) {
    // 配列準備
    List<Decimal> assholeFinalBalance = new List(); //タンス預金（年）
    List<Decimal> simpleInterestBalance = new List(); //単利計算（年）
    List<Decimal> compoundInterestBalance = new List(); //複利計算（年）
    List<Decimal> compoundCalculationBalance = new List(); //複利計算（月）

    // INITIALIZE
    assholeFinalBalance.add(currentBalance);
    simpleInterestBalance.add(currentBalance);
    compoundInterestBalance.add(currentBalance);
    compoundCalculationBalance.add(currentBalance);

    int count = 1; // 月カウント
    int countYear = 1; // 年カウント

    Decimal compoundMonthValue; // 毎月の金額
    Decimal compoundYearValue; // 毎年の金額

    /*
    * 計算ループ　
    * 毎月の金額を計算（小数第２位までで四捨五入）し、
    * １年の節目で年額を計算する。
    */
    while (count < periodYear * 12 + 1) {
      if (count % 6 == 0) {
        compoundMonthValue =
            ((((compoundCalculationBalance[count - 1] + monthlyAddition) *
                            interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);
      } else {
        compoundMonthValue =
            (((compoundCalculationBalance[count - 1] * interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);
      }

      if (count % 12 == 0) {
        // タンス預金
        assholeFinalBalance.add(currentBalance +
            ((monthlyAddition *
                Decimal.fromInt(2) *
                Decimal.fromInt(countYear))));
        // 単利計算
        simpleInterestBalance.add(((currentBalance +
                        (monthlyAddition *
                            Decimal.fromInt(2) *
                            Decimal.fromInt(countYear)) +
                        (currentBalance *
                            interestRateYear /
                            Decimal.fromInt(100) *
                            Decimal.fromInt(countYear))) *
                    Decimal.fromInt(10))
                .round() /
            Decimal.fromInt(10));
        // 複利計算
        compoundYearValue = (compoundMonthValue * Decimal.fromInt(10)).round() /
            Decimal.fromInt(10);
        compoundInterestBalance.add(compoundYearValue);

        print('Asshole=${assholeFinalBalance[countYear]}');
        print('Tanri=${simpleInterestBalance[countYear]}');
        print('Fukuri=${compoundInterestBalance[countYear]}');

        countYear++;
      }
      count++;
    }

    // 画面表示をset
    setState(() {
      _outputFinalAsshole = assholeFinalBalance[countYear - 1].toString();
      _outputFinalSimpleBalance =
          simpleInterestBalance[countYear - 1].toString();
      _outputFinalCompoundBalance =
          compoundInterestBalance[countYear - 1].toString();
      _outputGrowthRate = ((compoundInterestBalance[countYear - 1].toDouble() /
                  assholeFinalBalance[countYear - 1].toDouble())
              .round())
          .toString();
    });
  }

  // 積立タイプ６ヶ月
  void calcValueOneYear(
    Decimal currentBalance,
    Decimal monthlyAddition,
    Decimal interestRate,
    int periodYear,
    Decimal interestRateYear,
  ) {
    // 配列準備
    List<Decimal> assholeFinalBalance = new List(); // タンス預金（年）
    List<Decimal> simpleInterestBalance = new List(); // 単利計算（年）
    List<Decimal> compoundInterestBalance = new List(); // 複利計算（年）
    List<Decimal> compoundCalculationBalance = new List(); // 複利計算（月）

    // INITIALIZE
    assholeFinalBalance.add(currentBalance);
    simpleInterestBalance.add(currentBalance);
    compoundInterestBalance.add(currentBalance);
    compoundCalculationBalance.add(currentBalance);

    int count = 1; // 月カウント
    int countYear = 1; // 年カウント

    Decimal compoundMonthValue; // 毎月の金額
    Decimal compoundYearValue; // 毎年の金額

    /*
    * 計算ループ　
    * 毎月の金額を計算（小数第２位までで四捨五入）し、
    * １年の節目で年額を計算する。
    */
    while (count < periodYear * 12 + 1) {
      if (count % 12 == 0) {
        // タンス預金
        assholeFinalBalance.add(
            currentBalance + ((monthlyAddition * Decimal.fromInt(countYear))));
        // 単利計算
        simpleInterestBalance.add(((currentBalance +
                        (monthlyAddition * Decimal.fromInt(countYear)) +
                        (currentBalance *
                            interestRateYear /
                            Decimal.fromInt(100) *
                            Decimal.fromInt(countYear))) *
                    Decimal.fromInt(10))
                .round() /
            Decimal.fromInt(10));

        // 複利計算
        compoundMonthValue =
            ((((compoundCalculationBalance[count - 1] + monthlyAddition) *
                            interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);

        compoundYearValue = (compoundMonthValue * Decimal.fromInt(10)).round() /
            Decimal.fromInt(10);
        compoundInterestBalance.add(compoundYearValue);

        print('Asshole=${assholeFinalBalance[countYear]}');
        print('Tanri=${simpleInterestBalance[countYear]}');
        print('Fukuri=${compoundInterestBalance[countYear]}');

        countYear++;
      } else {
        compoundMonthValue =
            (((compoundCalculationBalance[count - 1] * interestRate) *
                        Decimal.fromInt(100))
                    .round() /
                Decimal.fromInt(100));
        compoundCalculationBalance.add(compoundMonthValue);
      }
      count++;
    }

    // 画面表示をset
    setState(() {
      _outputFinalAsshole = assholeFinalBalance[countYear - 1].toString();
      _outputFinalSimpleBalance =
          simpleInterestBalance[countYear - 1].toString();
      _outputFinalCompoundBalance =
          compoundInterestBalance[countYear - 1].toString();
      _outputGrowthRate = ((compoundInterestBalance[countYear - 1].toDouble() /
                  assholeFinalBalance[countYear - 1].toDouble())
              .round())
          .toString();
    });
  }

  // 数値クリア処理
  void allClear() {
    _currentBalanceFocusNode.unfocus();
    _monthlyAdditionFocusNode.unfocus();
    _interestRateYearFocusNode.unfocus();
    _periodYearFocusNode.unfocus();
    this.setState(() {
      _controllerCurrentBalance.clear();
      _controllerMonthlyAddition.clear();
      _controllerInterestRateYear.clear();
      _controllerPeriodYear.clear();
      this._additionalType = '1';
      this._inputCurrentBalance = null;
      this._inputMonthlyAddition = null;
      this._inputInterestRateYear = null;
      this._inputPeriodYear = null;
      this._inputInterestRateMonthActualNumber = null;
      this._inputInterestRateYearActualNumber = null;
    });
    final snackBarClear = SnackBar(
      content: Text('クリアしました！'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    // Find the Scaffold in the widget tree and use
    // it to show a SnackBar.
    _scaffoldKey.currentState.showSnackBar(snackBarClear);
  }

  @override
  void initState() {
    _additionalType = '1';
    _outputFinalAsshole = '0';
    _outputFinalSimpleBalance = '0';
    _outputFinalCompoundBalance = '0';
    _outputGrowthRate = '0';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false, // キーボード出現によるWidget高さ自動調整をオフ
      appBar: AppBar(
        title: const Text('iCC 複利計算',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            )),
      ),
      body: SafeArea(
        child: KeyboardActions(
          config: _buildConfig(context),
          child: GestureDetector(
            onTap: () {
              _currentBalanceFocusNode.unfocus();
              _monthlyAdditionFocusNode.unfocus();
              _interestRateYearFocusNode.unfocus();
              _periodYearFocusNode.unfocus();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: Center(
                            child: Text(
                              '計算条件',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Arial',
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ), //ENTER ITEMS
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 10.0, 25.0, 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '元本（万円）',
                              hintText: '数値を入力',
                              hintStyle: TextStyle(color: Colors.grey),
                              suffixText: '万円',
                              suffixStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  height: 0.8,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto'),
                              icon: Icon(
                                Icons.attach_money,
                                size: 35.0,
                              ),
                              fillColor: Colors.blueAccent,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              counterText: '',
                            ),
                            controller: _controllerCurrentBalance,
                            keyboardType: TextInputType.number,
                            focusNode: _currentBalanceFocusNode,
                            maxLength: 8,
                            maxLengthEnforced: true,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 0.8,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto'),
                            onChanged: setDecimalCurrentBalance,
                          ),
                        ), //元本（万円）
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 25.0, 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '積立金額（万円）',
                              hintText: '数値を入力',
                              hintStyle: TextStyle(color: Colors.grey),
                              suffixText: '万円',
                              suffixStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  height: 0.8,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto'),
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 35.0,
                              ),
                              fillColor: Colors.blueAccent,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              counterText: '',
                            ),
                            controller: _controllerMonthlyAddition,
                            keyboardType: TextInputType.number,
                            focusNode: _monthlyAdditionFocusNode,
                            maxLength: 8,
                            maxLengthEnforced: true,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 0.8,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto'),
                            onChanged: setDecimalMonthlyAddition,
                          ),
                        ), //積立金額（万円）
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 25.0, 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '年利（％）',
                              hintText: '数値を入力',
                              hintStyle: TextStyle(color: Colors.grey),
                              suffixText: '％',
                              suffixStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  height: 0.8,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto'),
                              icon: Icon(
                                Icons.cached,
                                size: 35.0,
                              ),
                              fillColor: Colors.blueAccent,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              counterText: '',
                            ),
                            controller: _controllerInterestRateYear,
                            keyboardType: TextInputType.number,
                            focusNode: _interestRateYearFocusNode,
                            maxLength: 4,
                            maxLengthEnforced: true,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 0.8,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto'),
                            onChanged: setDecimalInterestRateYear,
                          ),
                        ), //年利（％）
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 25.0, 10.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: '投資期間（年）',
                              hintText: '数値を入力',
                              hintStyle: TextStyle(color: Colors.grey),
                              suffixText: '年',
                              suffixStyle: TextStyle(
                                  color: Colors.blueAccent,
                                  height: 0.8,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto'),
                              icon: Icon(
                                Icons.schedule,
                                size: 35.0,
                              ),
                              fillColor: Colors.blueAccent,
                              hoverColor: Colors.blueAccent,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              counterText: '',
                            ),
                            controller: _controllerPeriodYear,
                            keyboardType: TextInputType.number,
                            focusNode: _periodYearFocusNode,
                            maxLength: 2,
                            maxLengthEnforced: true,
                            style: TextStyle(
                                fontSize: 16.0,
                                height: 0.8,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto'),
                            onChanged: setDecimalPeriodYear,
                          ),
                        ), //投資期間（年）
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Row(children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Text(
                                '積立タイプ',
                                style: TextStyle(
                                    fontSize: 19.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                    color: Colors.black54),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: DropdownButton(
                                value: _additionalType,
                                items: [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text(
                                      '1ヶ月ごと',
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text(
                                      '2ヶ月ごと',
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '6',
                                    child: Text(
                                      '6ヶ月ごと',
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: '12',
                                    child: Text(
                                      '12ヶ月ごと',
                                      style: TextStyle(
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Roboto',
                                          color: Colors.black54),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _additionalType = value;
                                  });
                                },
                                iconEnabledColor: Colors.blueAccent,
                              ),
                            ),
                          ]),
                        ), //積立タイプ
                      ],
                    ),
                  ),
                ), // 計算条件
                Card(
                  margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                          child: Center(
                            child: Text(
                              '計算結果',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Text(
                            '投資総額：' + _outputFinalAsshole + '万円',
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Text(
                            '単利金額：' + _outputFinalSimpleBalance + '万円',
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Text(
                            '複利金額：' + _outputFinalCompoundBalance + '万円',
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 10.0),
                          child: Text(
                            '増加率　：' + _outputGrowthRate + '％',
                            style: TextStyle(
                              fontSize: 21.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 120.0),
                          child: RaisedButton.icon(
                            highlightElevation: 16.0,
                            highlightColor: Colors.orangeAccent,
                            splashColor: Colors.purple,
                            icon: Icon(
                              Icons.restore_from_trash,
                              color: Colors.blueGrey,
                              size: 45.0,
                            ),
                            label: Text(
                              '条件をクリアする',
                              style: TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Roboto',
                                  color: Colors.blueGrey),
                            ),
                            color: Colors.white,
                            shape: Border(
                              top: BorderSide(color: Colors.red, width: 2.0),
                              left: BorderSide(color: Colors.blue, width: 2.0),
                              right:
                                  BorderSide(color: Colors.yellow, width: 2.0),
                              bottom:
                                  BorderSide(color: Colors.green, width: 2.0),
                            ),
                            onPressed: allClear,
                          ),
                        ),
                      ],
                    ),
                  ),
                ), // 計算結果
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: buttonPressed,
        icon: new Icon(
          Icons.tag_faces,
          size: 40.0,
        ),
        label: Text('GO!',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 35.0,
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

---
title: "아라비아 숫자와 자바의 로케일"
date: 2022-05-19T23:18:02+09:00
images:
categories:
- 개발
tags:
- JAVA
- Locale
---

### 날짜 문자열에 이상한 문자가 들어있다

{{< link "AWS v4 서명" "https://docs.aws.amazon.com/ko_kr/general/latest/gr/signature-version-4.html">}}과 관련하여 {{< bold "Authentication Header" >}}를 작성하다가 어떤 문제가 리포트 되었다.
인증 헤더에 {{< bold "Non-Ascii" >}} 코드가 들어있다는 리포트에 뭔가 이상하다 싶어 살펴보았더니 date 포맷의 스트링에 다음과 같은 문자열이 들어있다는 답변을 받는다.
```console
Ù¢Ù\xa0Ù¢Ù¢Ù\xa0Ù¤Ù¢Ù©TÙ\xa0Ù\xa0Ù¤Ù£Ù¡Ù©Z
```
정상적으로 작동했다면 원래 다음과 같은 값이 들어 있어야만 했다.
```console
20220429T004319Z
```
멀쩡한 숫자가 들어가야할 위치에 깨진 문자열이 들어간 것을 보고 당혹스럽기 그지 없었다.
혹시 {{< link "UTF-8" "https://ko.wikipedia.org/wiki/UTF-8">}} 포맷이 잘못 전송된 것은 아닐까 의심이 들어 Hex 코드로 변경하였더니 다음과 같은 값을 확인할 수 있었다.
```console
D9 A2 D9 A0 D9 A2 D9 A2 D9 A0 D9 A4 D9 A2 D9 A9 T D9 A0 D9 A0 D9 A4 D9 A3 D9 A1 D9 A9 Z
```
이를 유니코드로 변경하니 다음과 같은 값을 얻을 수 있었다.
```console
٢٠٢٢٠٤٢٩T٠٠٤٣١٩Z
```
자세히 살펴보니 원래 의도했던 값과 결과가 비슷해보였다. ٢를 2에, ٠을 0에 매칭시키면 벌서 앞에 문자가 20220으로 변환되는 것이 보인다. 혹시 국가나 로케일과 관련된 문제인가 싶어 해당 문제가 발생한 로그의 언어 코드를 보니 대부분이 {{< bold "ar" >}}이고, {{< bold "fa" >}}와 {{< bold "my" >}}인 로그도 간혹 보였다. 각각 {{< bold "아랍어" >}}, {{< bold "페르시아어" >}}, {{< bold "미얀마어" >}}에 해당하는 코드로 아랍권 문자라는 사실을 깨달았다. 설마 싶어서 확인해보니 아랍권에서는 {{< bold "아라비아 숫자가 아닌 다른 숫자" >}}를 사용하고 있었다. {{< bold "이름이 아라비아 숫자인데 아랍권에서 사용하는 숫자가 정작 다른 숫자" >}}라는 사실에 무척 당황해하며 검색해보니 재미있는 이야기를 찾아볼 수 있었다.

{{< image "images/numeral.PNG" "출처: https://ko.wikipedia.org/wiki/%EC%95%84%EB%9D%BC%EB%B9%84%EC%95%84_%EC%88%AB%EC%9E%90">}}

우리가 일반적으로 알고있는 0부터 9까지의 수체계는 {{< bold "서구 아라비아 숫자" >}}, 혹은 {{< bold "인도-아라비아 숫자" >}}라고 불리는 수체계다. 원래는 아라비아가 아니라 {{< bold "인도" >}}에서 발생한 수체계로 10세기 경에 아랍 상인들을 통해 유럽으로 전파되며 {{< bold "아라비아 숫자" >}}라는 이름을 얻게 된 것이다.

실제로 인도와 아랍권 국가에서 사용되는 아라비아 숫자의 형태는 {{< bold "동부 아라비아 숫자" >}}의 형태를 하고 있다. {{< bold "인도" >}}에서 발생한 {{< bold "아라비아" >}} 숫자를 인도에서도 아랍에서도 사용하지 않는 어지러운 현실을 직시하며, {{< bold "그렇다면 왜 동부 아라비아 숫자" >}}가 날짜 문자열에 들어갔는지 코드를 뜯어보았다.

### Java의 SimpleDateFormat

날짜를 저장하기 위해 자바에서 일반적으로 사용되는 클래스는 {{< bold "Date" >}}이다. Date는 내부적으로 밀리세컨드 단위로 시간 정보를 저장하며, 이를 문자열로 나타내기 위해 {{< bold "SimpleDateFormat" >}}이라는 클래스를 사용한다. SimpleDateFormat은 시간 단위를 나타내는 {{< bold "Format" >}} 문자열과 언어 설정인 {{< bold "Locale" >}}울 받아들여 사용한다. 가령, 우리가 날짜를 2022-05-20과 같이 연월일 순으로 나타내고 싶으면 Format 문자열에 "yyyy-mm-dd"를 넘기면 되고, 반대로 20-05-2022처럼 일월연 순으로 나타내고 싶으면 "dd-mm-yyyy"의 형태로 문자열을 넘기면 된다. Locale은 요일이나 달을 나타내는 특정 언어를 표현할 때 유용한데, 가령 "목요일"을 영어로 하면 "Thu", 일본어로 하면 "木"과 같은 다른 형식으로 표현된다. (이 경우 Format 문자열에 "EEE"를 넘기면 해당 값을 얻을 수 있다.) SimpleDateFormat을 이용하여 나타낼 수 있는 Format 표현식은 아래 표를 참조하자.

| **Letter** | **Date or Time Component**                       | **Presentation**   | **Examples**                          |
|------------|--------------------------------------------------|--------------------|---------------------------------------|
| G          | Era designator                                   | Text               | AD                                    |
| y          | Year                                             | Year               | 1996; 96                              |
| Y          | Week year                                        | Year               | 2009; 09                              |
| M          | Month in year                                    | Month              | July; Jul; 07                         |
| w          | Week in year                                     | Number             | 27                                    |
| W          | Week in month                                    | Number             | 2                                     |
| D          | Day in year                                      | Number             | 189                                   |
| d          | Day in month                                     | Number             | 10                                    |
| F          | Day of week in month                             | Number             | 2                                     |
| E          | Day name in week                                 | Text               | Tuesday; Tue                          |
| u          | Day number of week (1 = Monday, ..., 7 = Sunday) | Number             | 1                                     |
| a          | Am/pm marker                                     | Text               | PM                                    |
| H          | Hour in day (0-23)                               | Number             | 0                                     |
| k          | Hour in day (1-24)                               | Number             | 24                                    |
| K          | Hour in am/pm (0-11)                             | Number             | 0                                     |
| h          | Hour in am/pm (1-12)                             | Number             | 12                                    |
| m          | Minute in hour                                   | Number             | 30                                    |
| s          | Second in minute                                 | Number             | 55                                    |
| S          | Millisecond                                      | Number             | 978                                   |
| z          | Time zone                                        | General time zone  | Pacific Standard Time; PST; GMT-08:00 |
| Z          | Time zone                                        | RFC 822 time zone  | -0800                                 |
| X          | Time zone                                        | ISO 8601 time zone | -08; -0800; -08:00                    |


정작 중요한 문제는 내가 {{< bold "Locale에 영향을 받는 것은 요일, 월 등의 숫자가 아닌 문자" >}}에만 해당한다고 착각하고, 어차피 숫자만 사용할 테니깐 SimpleDateFormat을 만들 때 {{< bold "Default Locale" >}}로 설정을 해 놓았다는 점이다. 결국 아랍계 언어 locale이 설정되어 있을 경우, 아라비아 숫자가 아닌 다른 결과 값이 나와버려 위에서 언급한 문제가 발생했던 것이다. SimpleDateFormat을 만들 때 Locale을 English로 주면서 문제는 간단하게 해결되었다. 

참고로 중국어를 사용할 때 혹시 한자가 나오지 않을까 기대했는데 아쉽게도(?) 중국도 아라비아 숫자를 쓰는 모양이다. 아래 Locale 별로 정리된 출력물이 있으니 궁금하면 참조하길 바란다.

예제:
```java
Date date = new Date();
System.out.println("default: " + date.toString());
System.out.println("english: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.ENGLISH).format(date));
System.out.println("korean: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.KOREAN).format(date));
System.out.println("japanese: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.JAPANESE).format(date));
System.out.println("chinese: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.CHINESE).format(date));
System.out.println("traditional chinese: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.TRADITIONAL_CHINESE).format(date));
System.out.println("germany: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", Locale.GERMANY).format(date));
System.out.println("arabic: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", new Locale("ar")).format(date));
System.out.println("persian: " + new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss", new Locale("fa")).format(date));
```
결과:
```console
default: Thu May 19 16:50:35 GMT 2022
english: Thu, 19 May 2022 16:50:35
korean: 목, 19 5월 2022 16:50:35
japanese: 木, 19 5月 2022 16:50:35
chinese: 周四, 19 5月 2022 16:50:35
traditional chinese: 週四, 19 5月 2022 16:50:35
germany: Do., 19 Mai 2022 16:50:35
arabic: الخميس, ١٩ مايو ٢٠٢٢ ١٦:٥٠:٣٥
persian: پنجشنبه, ۱۹ مهٔ ۲۰۲۲ ۱۶:۵۰:۳۵
```
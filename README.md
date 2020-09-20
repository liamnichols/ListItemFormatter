#  ListItemFormatter

[![Build Status](https://travis-ci.org/liamnichols/ListItemFormatter.svg?branch=master)](https://travis-ci.org/liamnichols/ListItemFormatter)

`ListItemFormatter` is an `NSFormatter` subclass that supports formatting list items to the [Unicode CLDR specification](https://www.unicode.org/reports/tr35/tr35-53/tr35-general.html#ListPatterns).

## Usage

### Basic Formatting

```swift
let formatter = ListItemFormatter()
formatter.string(from: ["Liam", "Jack", "John"]) // "Liam, Jack and John"
```

### Modes & Styles

A `style` and `mode` property allow formatting for different types of data (such as units) as well as differnet length variations

```swift
let formatter = ListItemFormatter()
formatter.mode = .standard
formatter.string(from: ["Liam", "Jack", "John"]) // "Liam, Jack and John"

formatter.mode = .or
formatter.string(from: ["Liam", "Jack"]) // "Liam or Jack"

formatter.mode = .unit
formatter.style = .narrow
formatter.string(from: ["5ft", "6in"]) // "5ft 6in"

formatter.mode = .unit
formatter.style = .default
formatter.string(from: ["5 feet", "6 inch"]) // "5 feet, 6 inch"
```

### Localisation

The formatter is backed by an export of the Unicode CLDR data (version 35) and just like any other standard `NSFormatter` you can simply set the `locale` property to take advantage of over 200 languages and regional formats configurations provided.

```swift
let formatter = ListItemFormatter()
formatter.locale = Locale(identifier: "ar_LB")
formatter.string(from: ["ليام", "ليندا", "كوكباد"])
// "ليام، ليندا، وكوكباد"
```

Here is the complete list of supported language, region, and script code variants:

> Afrikaans, Aghem, Akan, Albanian, Amharic, Arabic, Armenian, Assamese, Asturian, Asu, Azerbaijani, Bafia, Bambara, Bangla, Basaa, Basque, Belarusian, Bemba, Bena, Bodo, Bosnian, Bosnian (Cyrillic), Breton, Bulgarian, Burmese, Cantonese, Cantonese (Simplified Han), Catalan, Catalan (Spain), Central Atlas Tamazight, Central Kurdish, Chakma, Chechen, Cherokee, Chiga, Chinese, Chinese (Hong Kong (China)), Chinese (Traditional Han), Church Slavic, Colognian, Cornish, Croatian, Czech, Danish, Duala, Dutch, Dzongkha, Embu, English, English (Australia), English (United Kingdom), English (United States), Esperanto, Estonian, Ewe, Ewondo, Faroese, Filipino, Finnish, French, Friulian, Fulah, Galician, Ganda, Georgian, German, Greek, Gujarati, Gusii, Hausa, Hawaiian, Hebrew, Hindi, Hungarian, Icelandic, Igbo, Inari Sami, Indonesian, Interlingua, Irish, Italian, Japanese, Javanese, Jola-Fonyi, Kabuverdianu, Kabyle, Kako, Kalaallisut, Kalenjin, Kamba, Kannada, Kashmiri, Kazakh, Khmer, Kikuyu, Kinyarwanda, Konkani, Korean, Koyra Chiini, Koyraboro Senni, Kurdish, Kwasio, Kyrgyz, Lakota, Langi, Lao, Latvian, Lingala, Lithuanian, Low German, Lower Sorbian, Luba-Katanga, Luo, Luxembourgish, Luyia, Macedonian, Machame, Makhuwa-Meetto, Makonde, Malagasy, Malay, Malayalam, Maltese, Manx, Maori, Marathi, Masai, Mazanderani, Meru, Metaʼ, Mongolian, Morisyen, Mundang, Nama, Nepali, Ngiemboon, Ngomba, North Ndebele, Northern Luri, Northern Sami, Norwegian Bokmål, Norwegian Nynorsk, Nuer, Nyankole, Odia, Oromo, Ossetic, Pashto, Persian, Polish, Portuguese, Prussian, Punjabi, Quechua, Romanian, Romansh, Rombo, Rundi, Russian, Rwa, Sakha, Samburu, Sango, Sangu, Scottish Gaelic, Sena, Serbian, Serbian (Latin), Shambala, Shona, Sichuan Yi, Sindhi, Sinhala, Slovak, Slovenian, Soga, Somali, Spanish, Spanish (Dominican Republic), Spanish (Paraguay), Standard Moroccan Tamazight, Swahili, Swedish, Swiss German, Tachelhit, Taita, Tajik, Tamil, Tasawaq, Tatar, Telugu, Teso, Thai, Tibetan, Tigrinya, Tongan, Turkish, Turkmen, Ukrainian, Upper Sorbian, Urdu, Urdu (India), Uyghur, Uzbek, Vai, Vietnamese, Volapük, Vunjo, Walser, Welsh, Western Frisian, Wolof, Xhosa, Yangben, Yiddish, Yoruba, Zarma, Zulu

### Attributed Strings

The `defaultAttributes` and `itemAttributes` allow for customising the object returned by `attributedString(from:)` in order to add special text effects such as highlighting of list items

```swift
let formatter = ListItemFormatter()
formatter.mode = .or
formatter.defaultAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]
formatter.itemAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold)]
formatter.attributedString(from: ["Swift", "Objective-C"]) // NSAttributedString

/*
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="Content-Style-Type" content="text/css">
    <title></title>
    <meta name="Generator" content="Cocoa HTML Writer">
    <style type="text/css">
      p.p1 {margin: 0.0px 0.0px 0.0px 0.0px; font: 12.0px '.SF UI Text'}
      span.s1 {font-family: '.SFUIText-Semibold'; font-weight: bold; font-style: normal; font-size: 12.00pt}
      span.s2 {font-family: '.SFUIText'; font-weight: normal; font-style: normal; font-size: 12.00pt}
    </style>
  </head>
  <body>
    <p class="p1"><span class="s1">Swift</span><span class="s2"> or </span><span class="s1">Objective-C</span></p>
  </body>
</html>
*/
```

## Installation

### Carthage

To integrate ListItemFormatter into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```
github "liamnichols/ListItemFormatter"
```

Follow the [instructions](https://github.com/Carthage/Carthage#quick-start) to add ListItemFormatter.framework to your project.

### CocoaPods

You want to add `pod 'ListItemFormatter', '~> 0.1'` similar to the following to your Podfile:

```ruby
target 'MyApp' do
  pod 'ListItemFormatter', '~> 0.1'
end
```

Then run `pod install` inside your terminal, or from CocoaPods.app. Alternatively to give it a test run, run the following command:

```sh
pod try ListItemFormatter
```

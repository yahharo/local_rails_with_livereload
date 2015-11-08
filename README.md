local_rails_with_livereload
====

※ローカルでの開発利用専用

## Description

assets周りを修正する場合に、gulpのliverelaodを使いたかっただけ。
プロキシとしてrailsに振る所は振る。

* sprockets入れ替えればとかそういうのは今はしんどいのでやめとく
* middlewareに書けばとかそういうのは今はしんどいのでやめとく

## Requirement

* ローカルでRailsが動く環境
* Node.js
* gulp
* 他はpackage.jsonを参照

## Usage

1. ローカルでRailsを立ち上げる
1. setting.jsonに設定を記載しておく
1. （ログインが必要なら）同じブラウザでログインしておく
1. gulp起動
```
gulp
```
1. 開発してると、あらまliverelaodに！

細かいことは後で書く

## Setting

## Install

```
npm install -g gulp
npm install .
```
なんだけど細かいことは後で書く

## Contribution

as you like it

## Licence

MIT

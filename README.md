# SaGa1DX

魔界塔士Sa・Ga をカラー化するパッチです。

<img width="400" src="https://gyazo.com/da9d082677a2e003dafa1da1ab3dc01b.jpeg" /><img width="400" src="https://gyazo.com/ece190625599eb1d4b39619c7cb5b11d.jpeg" />

<img width="400" src="https://gyazo.com/036a77a4d79b0336651c0938d52485f4.jpeg" /><img width="400" src="https://gyazo.com/baea63838d82d16bd75d0b3a39ee91b8.jpeg" />

## 使い方

[こちら](https://github.com/akatsuki105/saga1dx/releases)から最新の `SaGa1DX.ips` をダウンロードして、[ROM Patcher JS](https://www.romhacking.net/patch/index.php) などでパッチを当ててください。

## ビルド

自分でパッチをビルドする際には、 [rgbds](https://github.com/gbdev/rgbds) が必要です。
このレポジトリのルートに `SaGa1.gb` を配置して、
```sh
make      # -> build/SaGa1DX.gbc
```

パッチファイル`.ips`が欲しい場合は、追加で [Flips](https://github.com/Alcaro/Flips) が必要になります。 (`SaGa1DX.gbc`をビルドしてから差分を抽出して`.ips`を作ってます。)

```sh
make ips  # -> build/SaGa1DX.ips
```

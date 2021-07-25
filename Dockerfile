FROM python:3.8.10-buster

RUN pip install pylint

# zshをインストール
RUN apt-get update -qq && apt-get install -y zsh
# デフォルトのシェルをzshに変更
RUN chsh -s /bin/zsh

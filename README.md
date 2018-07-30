# docker化ORB-SLAM2
[ORB-SLAM2](https://github.com/raulmur/ORB_SLAM2) をdocker で動かせるようにしたものです。
ROSを使って動かすものと、使わず動かすもの両方に対応しています。

# License
GPLv3

# 実行環境
VirtualBox 上のubuntu 16.04 では動作確認できています。
nvidia、amdのグラフィックカードを使った環境でなければ動くと思います。

# 実行方法

## 環境設定

```
git clone https://github.com/ft28/dockernized_orb_slam2.git 
cd dockernized_orb_slam2
git submodule update --init --recursive
```

.bashrc に以下の設定を書き込みます。

```.bashrc
# docker 上で現在のユーザーとグループを使うための設定
export USER_ID=`id -u`
export USER_NAME=`id -nu`
export GROUP_ID=`id -g`
export GROUP_NAME=`id -ng`

# docker 上でx-window を使うための設定
export XSOCK=/tmp/.X11-unix
export XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
```

反映します。

```
source ~/.bashrc
```

## イメージ作成
```
docker-compose build orb_slam2_ros
```

## 起動
コンテナ上で、bashが起動した状態になります。
```
docker-compose run orb_slam2_ros
```

# 使い方
## 設定
orb_slam_ros_home 以下をdocker 環境内のhomeにマウントして使います。
初めて起動するときに、ROS環境の初期化とORB_SLAM2のコンパイルを行います。
catkin_ws 内部のファイルをすべて削除すると、再度ROS環境の初期化とORB_SLAM2のコンパイルが実行されます。詳しくは、entrypoint.sh を参照してください。

docker-composeでは、実験データは、ホスト環境の/opt/data 以下にあると想定しています。他の場所に置く場合は、docker-compose.yml を修正してください。

## サンプルデータ取得

[EuRoC Dataset](https://projects.asl.ethz.ch/datasets/doku.php?id=kmavvisualinertialdatasets) からテスト用にデータをダウンロードします。

```
# ROS実験用
wget -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.bag

# 非ROS実験用
wget -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.zip
```

ダウンロードしたデータをホストマシンの/opt/data 以下に保存します。zipファイルは解凍しておきます。

```
ls /opt/data
MH_01_easy.bag  mav0
```

## サンプルデータ実行

コンテナ起動します。

```
docker-compose run orb_slam2_ors
```
### 非ROS実行
cd ORB_SLAM2
./Examples/Stereo/stereo_euroc ./Vocabulary/ORBvoc.txt ./Examples/Stereo/EuRoC.yaml /opt/data/mav0/cam0/data /opt/data/mav0/cam1/data ./Examples/Stereo/EuRoC_TimeStamps/MH01.txt

### ROS実行
tmux で複数ウィンドウを開いてROSを実行します。

```
cd ORB_SLAM2
tmux 
# ウィンドウ1でroscore 実行
roscore

# ウィンドウ2でORB_SLAM実行
rosrun ORB_SLAM2 Stereo Vocabulary/ORBvoc.txt Examples/Stereo/EuRoC.yaml true

# ウィンドウ3でbagファイル再生
rosbag play --pause /opt/data/MH_01_easy.bag /cam0/image_raw:=/camera/left/image_raw /cam1/image_raw:=/camera/right/image_raw
```

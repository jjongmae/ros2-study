# ros2-study

TurtleBot3 Gazebo 시뮬레이터로 ROS2(Humble) 구동 원리를 익히기 위한 실습 워크스페이스입니다.

## 구성

```
ros2-study/
├── Dockerfile          # osrf/ros:humble-desktop + turtlebot3 패키지
├── docker-compose.yml  # GPU, host 네트워크, X11, 폴더 마운트
├── .gitignore
└── src/                # 직접 만든 ROS2 패키지
```

호스트의 이 폴더가 컨테이너의 `/root/ros2-study`에 마운트됩니다.

## 시작하기

```bash
# 이미지 빌드 + 컨테이너 실행
docker compose up -d --build

# 컨테이너 접속 (터미널마다 실행)
docker compose exec ros2 bash
```

### 시뮬레이터 실행

```bash
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
```

### 키보드로 조작 (다른 터미널)

```bash
ros2 run turtlebot3_teleop teleop_keyboard
```

- 키 입력은 이 터미널이 선택된 상태에서만 먹습니다 (Gazebo 창 X)
- `w`/`x` 전진·후진 속도, `a`/`d` 회전 속도, `space` 정지

## 구동 원리

```
teleop_keyboard ──/cmd_vel──▶ turtlebot3_diff_drive (Gazebo 플러그인) ──▶ 바퀴 구동
Gazebo 물리엔진 ──▶ /odom (위치), /scan (LiDAR), /camera/image_raw (카메라)
```

탐색용 명령:

```bash
ros2 node list
ros2 topic list
ros2 topic echo /odom --field pose.pose.position
ros2 topic echo /scan --once
rqt_graph
ros2 run rqt_image_view rqt_image_view
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.1}}"
```

## 환경 설정 메모

| 설정 | 이유 |
|---|---|
| `TURTLEBOT3_MODEL=waffle` | 사용할 로봇 모델 지정 |
| `GAZEBO_MODEL_DATABASE_URI=""` | 온라인 모델 DB 접속 대기로 멈추는 현상 방지 |
| `GAZEBO_MODEL_PATH=/usr/share/gazebo-11/models` | 없으면 `ground_plane`이 안 떠서 로봇이 무한 낙하 |

위 값은 Dockerfile의 `ENV`로 들어가 있어 `docker exec` 셸에서도 적용됩니다.

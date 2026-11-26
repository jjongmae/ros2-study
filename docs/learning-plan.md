# ROS2 학습 계획

TurtleBot3 시뮬레이터를 **관찰하고 만져보며** ROS2 구조를 파악하는 계획입니다.
코드를 짜기 전에, 이미 돌아가는 시스템을 읽는 것부터 시작합니다.

> 실행 방법은 [README](../README.md), 배운 점은 [learning-log](learning-log.md)에 기록합니다.
> 아래 명령은 모두 컨테이너 안에서 실행합니다.
> (시뮬레이터가 켜져 있어야 합니다)

## 진행 방식

- 한 번에 한 질문씩: "이 토픽은 누가 만들고 누가 쓰는가?"
- 단계마다 체크박스를 채우고, 배운 점은 [learning-log](learning-log.md)에 적습니다.
- 막히면 `ros2 <명령> --help`
- 병행 자료: ROS2 Humble 공식 문서 *Beginner: CLI tools* (turtlesim 대신 터틀봇으로 바꿔서 실습)

---

## 1단계: 그래프 읽기 (노드, 토픽)

**핵심 개념:** 독립된 프로그램(노드)들이 토픽으로 메시지를 주고받는다.

**답하려는 질문**
- `/cmd_vel`은 누가 보내고 누가 받는가?
- `/scan`은 누가 만드는가?
- 노드는 총 몇 개이고, 각각 무슨 일을 하는가?

**실습**
```bash
rqt_graph                                    # 노드·토픽 연결 그림
ros2 node list
ros2 node info /turtlebot3_diff_drive        # 노드가 발행·구독하는 토픽
ros2 topic list -t                           # 토픽 이름 + 메시지 타입
ros2 interface show geometry_msgs/msg/Twist  # 메시지 구조
```

- [ ] rqt_graph를 보고 위 질문에 답했다
- [ ] 메시지 타입(Twist, LaserScan, Odometry)의 필드를 읽어 봤다

---

## 2단계: 데이터 직접 만져보기

**핵심 개념:** 입력(명령)과 출력(센서값)이 어떻게 연결되는가.

**답하려는 질문**
- 로봇이 움직일 때 `/odom`, `/scan`, `/imu` 값은 어떻게 변하는가?
- 카메라는 왜 다른 토픽보다 무거운가?

**실습**
```bash
ros2 topic echo /odom --field pose.pose.position
ros2 topic echo /scan --once
ros2 topic hz /scan                          # 발행 주기
ros2 topic bw /camera/image_raw              # 데이터량
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.1}}"
```

- [ ] teleop으로 움직이며 `/odom`이 바뀌는 걸 확인했다
- [ ] teleop 없이 `/cmd_vel`을 직접 발행해 봤다
- [ ] 센서별 발행 주기와 데이터량을 비교했다

---

## 3단계: 토픽 외의 통신 방식

**핵심 개념:** 토픽(스트림), 서비스(요청·응답), 파라미터(설정), 액션(오래 걸리는 작업).

**답하려는 질문**
- 토픽과 서비스는 어떤 경우에 각각 쓰는가?
- 노드의 설정값은 어디서 바꾸는가?

**실습**
```bash
ros2 service list -t
ros2 service type /pause_physics             # Gazebo 서비스 예시
ros2 param list
ros2 param get /turtlebot3_diff_drive use_sim_time
ros2 action list                             # 지금은 비어 있어도 정상 (Nav2에서 사용)
```

- [ ] 서비스 목록을 보고 토픽과의 차이를 설명할 수 있다
- [ ] 파라미터 하나를 조회했다

---

## 4단계: 좌표계(TF)와 로봇 모델

**핵심 개념:** vision·내비게이션에서 가장 많이 막히는 부분. Gazebo는 "진짜 세계", RViz는 "로봇이 인식하는 세계".

**답하려는 질문**
- 좌표계 트리(`odom → base_footprint → base_link → 센서`)는 어떻게 이어지는가?
- 센서 데이터는 어느 프레임 기준인가?

**실습**
```bash
ros2 run tf2_tools view_frames               # frames.pdf 생성
ros2 run tf2_ros tf2_echo odom base_link
rviz2                                        # RobotModel, LaserScan, TF 추가
```

- [ ] TF 트리를 그림으로 확인했다
- [ ] RViz에서 로봇 모델 + LiDAR + TF를 겹쳐 봤다
- [ ] Gazebo 화면과 RViz 화면의 차이를 설명할 수 있다

---

## 5단계: 시뮬레이터 구성 파일 읽기

**핵심 개념:** 어떤 파일이 무엇을 어떤 순서로 띄우는가. (읽기만 하고 수정하지 않음)

**답하려는 질문**
- launch 파일은 왜 노드 여러 개를 한꺼번에 띄우는가?
- 로봇의 센서와 플러그인은 어디에 정의되어 있는가?
- 월드에서 바닥이 빠지면 무슨 일이 생기는가? (한 번 겪어 봄)

**읽을 위치** (`/opt/ros/humble/share/turtlebot3_gazebo/`)
- `launch/` : 실행 순서와 구성
- `worlds/` : 월드 정의
- `models/` 및 URDF/SDF : 로봇 구조, 센서, Gazebo 플러그인

- [ ] `turtlebot3_world.launch.py`를 끝까지 읽었다
- [ ] 월드 파일과 로봇 모델 파일의 역할을 구분할 수 있다
- [ ] diff_drive 플러그인 설정(바퀴 간격, 토픽 이름)을 찾았다

---

## 6단계: 하나씩 바꿔 보기

**핵심 개념:** 관찰이 충분해진 뒤, 변수를 한 개씩 바꿔 결과를 비교.

**실습 후보**
- 월드 변경: `turtlebot3_house`
- 로봇 변경: `TURTLEBOT3_MODEL=burger` / `waffle_pi`
- `ROS_DOMAIN_ID`를 바꿔 통신이 분리되는 걸 확인 (DDS 개념)
- 그다음에 `src/`에 직접 패키지를 만들어 노드 작성

- [ ] 월드 또는 로봇을 바꿔 실행해 봤다
- [ ] `ROS_DOMAIN_ID` 변경 실험을 했다
- [ ] 첫 번째 직접 만든 노드의 주제를 정했다

---

## 나중에 볼 것

지금 단계에서는 필요 없지만 잊지 않으려고 적어 두는 목록입니다. 직접 노드를 짜는 6단계 이후에 필요해질 때 찾아봅니다.

| 주제 | 언제 필요한가 | 메모 |
|---|---|---|
| `message_filters` | 서로 다른 센서 메시지(카메라 + LiDAR/depth 등)를 시간 기준으로 맞춰 묶어 받을 때 | **회사에서 많이 쓰임.** 우선순위 높음 |
| `/map` (SLAM) | 로봇이 환경 지도를 만들 때 | |

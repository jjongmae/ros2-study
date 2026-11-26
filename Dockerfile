FROM osrf/ros:humble-desktop

# 터틀봇3 시뮬레이션 + 키보드 조작 + 편집기
RUN apt-get update && apt-get install -y --no-install-recommends \
      ros-humble-turtlebot3-gazebo \
      ros-humble-turtlebot3-teleop \
      nano \
    && rm -rf /var/lib/apt/lists/*

# 모든 셸(docker exec 포함)에서 적용되는 환경변수
ENV TURTLEBOT3_MODEL=waffle
# Gazebo가 온라인 모델 DB 접속을 시도하다 멈추는 현상 방지
ENV GAZEBO_MODEL_DATABASE_URI=""
# Gazebo 기본 모델(ground_plane, sun) 경로. 없으면 바닥이 없어 로봇이 무한 낙하함
ENV GAZEBO_MODEL_PATH=/usr/share/gazebo-11/models

# 인터랙티브 셸에서 ROS 환경 자동 로드 (빌드 전에는 install이 없어도 에러 없음)
RUN echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc && \
    echo '[ -f /root/ros2-study/install/setup.bash ] && source /root/ros2-study/install/setup.bash' >> /root/.bashrc

WORKDIR /root/ros2-study

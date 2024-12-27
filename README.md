# Project conducted in Robotics Laboratory 2
DE0 보드를 활용한 프로젝트를 진행하였고, 프로그래밍은 Altera Quartus에서 VHDL 언어로 이루어졌다. 

로봇은 IR 센서 8개를 장착하였으나, 실제 구현 시 센서의 오차를 보정하기 위해 6개의 IR 센서 데이터만을 사용하여 최종적으로 구현하였다.

21.57초의 기록으로 반에서 최종 1등이라는 기록을 달성하였다.

<img src="https://github.com/user-attachments/assets/1e478383-bd30-44f2-bc8d-743a14ff60df" alt="Description" style="width: 60%;">
<hr style="border-top: 3px solid #bbb;">

## Robot&Map Images

- 한 개의 가로 선의 경우는 멈추는 것을 구현
- 얇은 두 개의 가로 선의 경우는 신호등을 구현
- 두꺼운 두 개의 가로 선의 경우는 가속 구간을 구현
<div style="display: flex; justify-content: space-around; align-items: center;">
  <img src="https://github.com/user-attachments/assets/af79d44b-dcf5-4a49-9904-48fe3d5580b0" alt="Description1" style="width: 30%; height: 200px; margin-right: 2%;">
  <img src="https://github.com/user-attachments/assets/55896f91-41db-4f25-b69a-6841159d8ef9" alt="Description2" style="width: 30%; height: 200px;">
</div>

<div style="display: flex; justify-content: space-around;">
  <img src="https://github.com/user-attachments/assets/4680cdc7-4af4-4007-b154-bf3fa56a96f1" alt="Description1" style="width: 20%; height: 180px; margin-right: 2%;">
  <img src="https://github.com/user-attachments/assets/91b677ab-0271-45ea-9167-e0a290b641f6" alt="Description2" style="width: 20%; height: 180px; margin-right: 2%;">
  <img src="https://github.com/user-attachments/assets/61cd6b32-37fb-4d91-9aac-43c0cf3c059e" alt="Description3" style="width: 20%; height: 180px;">
</div>
<hr style="border-top: 3px solid #bbb;">

## circuit diagram
sensor
<div style="display: flex; justify-content: space-around; align-items: center;">
  <img src="https://github.com/user-attachments/assets/ee20c8ae-67f8-4024-8af2-1539c9a86ff0" alt="Description1" style="width: 30%; height: 200px; margin-right: 2%;">
  <img src="https://github.com/user-attachments/assets/d49f79ce-e576-40b6-acaf-c33a93a22274" alt="Description2" style="width: 30%; height: 200px;">
</div>
motor
<div style="display: flex; justify-content: space-around; align-items: center;">
  <img src="https://github.com/user-attachments/assets/67cdebfb-39a8-4de3-bccf-d878ee270114" alt="Description1" style="width: 30%; height: 200px; margin-right: 2%;">
  <img src="https://github.com/user-attachments/assets/f49f7ea7-b9e6-47e8-86f6-542e6a35ee61" alt="Description2" style="width: 30%; height: 200px;">
</div>
<hr style="border-top: 3px solid #bbb;">

## 프로젝트 진행 중 발생한 문제
IR 센서가 총 8개가 탑재되어 있는데, 각 센서마다 노이즈가 크게 발생하여 가로선을 지나갈 때 수평선을 정확히 1번 인식하지 못하는 문제가 발생하였다.
수평선을 지나갈 때 로봇이 선을 감지하는 횟수를 DE0 보드를 통해 디버그 해보니 수평선 1개를 지나갈 때, 노이즈로 인해 몇십개의 값을 카운트 하는 것을 인식하였다.
처음에는 노이즈를 줄이기 위해 직접 IR 센서의 저항 값을 조절해 보았는데 계속하여 문제가 발생하였다.
따라서 이러한 문제를 해결하기 위해 제어주기를 통한 특정 시간에서의 센서 값만을 취하는 방법을 적용하여 올바르게 수평선을 인식하도록 적용하였다.






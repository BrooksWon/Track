# Track
曝光统计

优化自 https://mp.weixin.qq.com/s/QQJxGleNylECxPF4whLMgA

增加了 

1.view被遮挡时不采集曝光；

2.view tree 手动变化时自动曝光之前被遮挡的view；

3.数据存储（使用mmap）、自动上报（app启动时）模块；


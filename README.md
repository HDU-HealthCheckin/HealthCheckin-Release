# 杭电自动健康打卡

- [x] 杭电新自动打卡
- [x] Telegram 机器人
- [x] 钉钉群机器人
- [x] Uptime Kuma 推送
- [x] 自动更新
- [x] 实现指数退避的重试

## 配置文件

配置文件使用 [viper](https://github.com/spf13/viper) 处理，任何它可识别的格式均可用。

在以下位置的配置文件会生效:

- `./config.[yaml/json/etc]`
- `/etc/HealthCheckin/config.[yaml/json/etc]`

以下以 yaml 为例，你也可参照项目下的 `config.example.yaml` 文件，按照自己的需要来配置，记得删去 `.example`。

### 必填设置

```yaml
profiles: # 推荐使用该方式配置
   - username: "xxxxxxxx" # 学号
     password: "xxxxxxxx" # 上课啦密码
   - username: "xxxxxxxx" # 学号
     password: "xxxxxxxx" # 上课啦密码
profile: # 该方式已过时 但是仍然兼容
   username: "xxxxxxxx" # 学号
   password: "xxxxxxxx" # 上课啦密码
```

- `username`: 学号
- `password`: 上课啦密码

### 选填设置

以下选项均选填，下方模板中的值即为默认值。

其中，`tgbot.token`, `dingtalk.token`, `uptimekuma.url` 和 `heartbeat.url` 若为空字符串，则禁用对应的模块。

```yaml
general:                         # 通用功能
  auto_update: true                # 是否自动更新
cron:                            # 计划任务
  time: "30 6 * * *"               # 计划任务开始时间，遵循 cron 格式
  random_min: 0                    # 随机延迟最小值 (单位: 秒)
  random_max: 3600                 # 随机延迟最大值 (单位: 秒)
  retry: 5                         # 最大重试次数 0 表示不重试 (默认 5) 推荐小于 8
  retry_interval: 5                # 最小重试间隔 (单位: 秒)
tgbot:                           # Telegram 推送
  token: ""                        # 机器人 Token
  chatid: 0                        # Chat ID
  endpoint: "api.telegram.org"     # Telegram Bot API Endpoint
  timeout: 10                      # Timeout 时间 (单位: 秒)
  retry: 5                         # 最大重试次数
dingtalk:                        # 钉钉群自定义机器人推送 https://open.dingtalk.com/document/robots/custom-robot-access
   token: ""                        # 钉钉机器人 Token（webhook url 最后那部分）
   endpoint: "oapi.dingtalk.com"    # 钉钉机器人 API Endpoint
   secret: ""                       # 钉钉机器人 Secret
   timeout: 10                      # Timeout 时间 (单位: 秒)
   retry: 5                         # 最大重试次数
uptimekuma:                      # Uptime Kuma 推送
  url: ""                          # Uptime Kuma Push 地址
  timeout: 10                      # Timeout 时间 (单位: 秒)
  retry: 5                         # 最大重试次数
heartbeat:                       # 心跳
  url: ""                          # 心跳请求 Push 地址
  timeout: 10                      # Timeout 时间 (单位: 秒)
  retry: 5                         # 最大重试次数
  time: "0 * * * *"                # 时间，遵循 cron 格式
```

## 使用方式

### 手动打卡

使用 `HealthCheckin now` 可立即完成一次打卡。

此时不会自动重试，如打卡失败可手工重新打卡。

### 安装与注册

预编译版本可前往 [GitHub Release](https://github.com/HDU-HealthCheckin/HealthCheckin-Release/releases/latest) 查看。

请自行更改下方下载链接以安装您所需的版本。

以下命令请使用 root 权限执行。

```shell
wget -O /usr/local/bin/HealthCheckin https://github.com/HDU-HealthCheckin/HealthCheckin-Release/releases/latest/download/HealthCheckin_linux_amd64 && chmod +x /usr/local/bin/HealthCheckin
vi /etc/HealthCheckin/config.yaml
```

### 服务管理

#### Systemd daemon

可以使用下列命令进行简单的服务管理:

- `HealthCheckin version` 查看当前二进制版本
- `HealthCheckin install` 注册服务
- `HealthCheckin remove` 移除服务
- `HealthCheckin run` 立即执行一次打卡
- `HealthCheckin start` 启动
- `HealthCheckin stop` 停止
- `HealthCheckin status` 查看服务状态

安装完成后即可使用 `HealthCheckin install && HealthCheckin start` 完成注册并启动。

除此以外，注册服务时，会以 `health-checkin` 在 `systemd` 中添加服务。因此可以通过该 Unit 名获取更多详细信息。

#### Docker daemon

1. 使用[上面的任意方法](#安装与注册)获取到可执行程序。

2. 获取 [Dockerfile](https://raw.githubusercontent.com/HDU-HealthCheckin/HealthCheckin-Release/master/Dockerfile)，与可执行程序放置在同一目录。

3. 修改配置后保存到 `/etc/HealthCheckin/config.yaml`

4. 使用 `docker build` 与 `docker run` 进行部署:

    ```shell
    docker build -t <image_name> .
    docker run -itd -v /etc/HealthCheckin/config.yaml:/config.yaml \
          -v /etc/timezone:/etc/timezone:ro \
          -v /etc/localtime:/etc/localtime:ro \
          --name=<container_name> <image_name>
    ```

具体可以参考 Dockerfile。

5. 命令：

* 查看日志：`docker logs -f <container_name>`

#### Docker compose 多账号部署

1. 参考 [Docker daemon](#docker-daemon) 完成第1-3步。
2. 修改 [docker-compose.yml](https://raw.githubusercontent.com/HDU-HealthCheckin/HealthCheckin-Release/master/docker-compose.yml) 中的配置，一个 service 代表一个账号，尤其是 volumes 中的源配置文件路径。
3. 命令

* 运行所有 Service：`docker-compose up -d`
* 运行指定 Service：`docker-compose up -d <service_name>`
* 停止所有 Service：`docker-compose down`
* 查看所有 Service 状态：`docker-compose ps`
* 查看所有 Service 日志：`docker-compose logs -f`

## 致谢

- [hduLib/hdu](https://github.com/hduLib/hdu)

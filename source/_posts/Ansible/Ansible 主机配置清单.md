> Ansible 系列：
>
> - （一）：[快速上手 Ansible](./Ansible 快速上手.md)
> - （二）：[Ansible 命令](./Ansible 命令.md)
> - （三）：[Ansible 主机清单配置文件](./Ansible 主机配置清单.md)
> - （四）：[Ansible Playbook 剧本语法](./Playbook 剧本语法.md)

## Ansible 主机配置清单文件

> 参考至[官方文档](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#)，官方文档包含了清单文件的 YAML 写法

**在通过 Ansible 操作目标主机之前，你需要先在 Inventory（主机清单）中配置目标主机信息。**

默认情况下主机清单保存在系统的 `/etc/ansible/hosts` 文件中，你也可以通过命令行选项指定其它的清单文件 **-i \<path>**。

主机清单配置默认格式为 INI，下面是一个主机清单配置例子：

```ini
[web] 
www.abc.com1
192.168.0.2
```

上述配置中方括号为组名，www.abc.com1 和 192.168.0.2 为被监控主机的域名或 IP。也可以是主机名，但此时需要指定主机 IP 环境变量 。

```ini
[web] 
node ansible_host=192.0.2.50
```

默认采用密钥认证，如果没有密钥认证，那么你需要配置主机密码环境变量。

```ini
[web] 
www.abc.com1 ansible_user=root ansible_password=123456
```

你也可以对指定组下的主机进行统一的环境变量配置：

```ini
[web] 
www.abc.com1 ansible_user=root ansible_password=123456 http_port=8080
192.168.0.2 ansible_user=root ansible_password=123451

[web:vars]
http_port=80
ssh_port=22
redis_port=6379
```

如果主机名或 IP 是有序有规则的，你还可以采用数字或字符范围格式，而不是列出每个主机名：

```ini
[webservers]
www[01:50].example.com

[databases]
db-[a:f].example.com
```

### 组的继承

组还支持继承（嵌套），其格式为 **组名+":children"** 组成，如下：

```ini
[shenzhen]
host1
host2
[guangzhou]
host3
host4
[guangdong:children]
shenzhen
guangzhou
[guangdong:vars]
tomcat=192.168.8.8
nginx=192.168.8.66
apache=192.168.8.77
zabbix=192.168.8.88
[china:children]
guangdong
beijing
shanghai
```

上面我指定了深圳组有 host1、host2，广州组有host3、host4。广东组包含深圳和广州，同时为该组内的所有主机指定了四个环境变量。后又设定了一个中国组，包含广东、北京、上海。

### 默认组

所有主机都属于两个隐式的组：

- **all：**包含每个主机
- **ungrouped：**除了 all 组之外没有其它组的主机

### 组织环境变量

环境变量除了写在主机清单文件中，还可以单独存储在单个文件中。

我们可以在主机清单文件的同级目录中创建两个目录 "group_vars" 和 "host_vars"，分别存储组变量与主机变量文件。

如我们在主机清单文件中声明了组 test，此时在 group_vars 目录下创建一个名为 test 的文件（该文件为 YAML 格式），其内容如下：

```
tomcat: 192.168.8.8
```

此时 test 组中的主机将会包含 tomcat 这个环境变量。

当 "group_vars" 或 "host_vars" 外部环境变量文件与主机清单文件中的环境变量冲突时，前者优先级更高。

### 特殊环境变量

Ansible 定义了一些固定的环境变量名，这些环境变量将会影响 Ansible 的行为。

```shell
ansible_connection #主机连接类型，这可以是任何 ansible 连接插件的名称，如 smart、ssh、paramiko、local
ansible_ssh_host # 将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.
ansible_ssh_port # 连接端口号（默认22）
ansible_ssh_user # 连接主机时的用户名
ansible_ssh_pass # 用于验证主机的密码
ansible_ssh_private_key_file # ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.
ansible_ssh_common_args # 此设置附加到 sftp，scp 和 ssh 的缺省命令行
ansible_sftp_extra_args # 此设置附加到默认 sftp 命令行
ansible_scp_extra_args # 此设置附加到默认 scp 命令行
ansible_ssh_extra_args # 此设置附加到默认 ssh 命令行
ansible_ssh_pipelining # 确定是否使用 SSH 管道。 这可以覆盖 ansible.cfg 中得设置
ansible_shell_type # 目标系统的 shell 类型，默认情况下命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'
ansible_python_interpreter # 目标主机的 python 路径，适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如 *BSD, 或者 /usr/bin/python
ansible_interpreter # 这里的""可以是 ruby、perl 或其他语言的解释器，作用和ansible_python_interpreter 类似
ansible_shell_executable # 这将设置 ansible 控制器将在目标机器上使用的 shell，覆盖 ansible.cfg 中的配置，默认为 /bin/sh
```
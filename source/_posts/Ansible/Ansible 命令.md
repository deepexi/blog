>Ansible 系列：
>
>- （一）：[快速上手 Ansible](./Ansible 快速上手.md)
>- （二）：[Ansible 命令](./Ansible 命令.md)
>- （三）：[Ansible 主机清单配置文件](./Ansible 主机配置清单.md)
>- （四）：[Ansible Playbook 剧本语法](./Playbook 剧本语法.md)

## Ansible 命令

### ansible

Ad-Hoc 即单条命令，指需要快速执行并且不需要保存的命令。默认不指定模块时，使用的是 Command 模块。

```shell
Usage: ansible <host-pattern> [options]

命令选项
-a # 模块的参数。
-B # 异步运行时，多长时间超时。
-P # 如果使用-B，则设置轮询间隔。
-C # 只是测试一下会改变什么内容，不会真正去执行;相反,试图预测一些可能发生的变化。
-D # 当更改文件和模板时，显示这些文件得差异，比--check效果好。
-f # 指定定要使用的并行进程数，默认为5个。
-i # 指定主机清单文件或逗号分隔的主机，默认为/etc/ansible/hosts。
-l # 进一步限制所选主机/组模式，只执行-l 后的主机和组。 也可以这样使用 -l @retry_hosts.txt
-m 　　# 要执行的模块，默认为command。
-M 　　# 要执行的模块的路径。
-o 　　# 压缩输出，摘要输出.尝试一切都在一行上输出。
-v, --verbose # 输出执行的详细信息，使用-vvv获得更多，-vvvv 启用连接调试
--version # 显示程序版本号
-e --extra-vars=EXTRA_VARS # 添加附加变量，比如key=value，yaml，json格式。
--list-hosts # 输出将要操作的主机列表，不会执行操作
--output=OUTPUT_FILE # 加密或解密输出文件名 用于标准输出。
--tree=TREE # 将日志内容保存在该目录中,文件名以执行主机名命名。
--syntax-check # 对playbook进行语法检查，且不执行playbook。
--ask-vault-pass # vault 密码。
--vault-password-file=VAULT_PASSWORD_FILE vault密码文件
--new-vault-password-file=NEW_VAULT_PASSWORD_FILE 新vault密钥文件。
 
 
连接选项:
-k --ask-pass # 要求用户输入请求连接密码
-u --user=REMOTE_USER # 连接远程用户
-c --connection=CONNECTION # 连接类型，默认smart，支持local ssh 和 paramiko
-T --timeout=TIMEOUT # 指定默认超时时间，默认是10S
--ssh-common-args=SSH_COMMON_ARGS # 指定要传递给sftp / scp / ssh的常见参数 （例如 ProxyCommand）
--sftp-extra-args=SFTP_EXTRA_ARGS # 指定要传递给sftp，例如-f -l
--scp-extra-args=SCP_EXTRA_ARGS # 指定要传递给scp，例如 -l
--ssh-extra-args=SSH_EXTRA_ARGS # 指定要传递给ssh，例如 -R
--private-key=PRIVATE_KEY_FILE, --key-file=PRIVATE_KEY_FILE 私钥路径，使用这个文件来验证连接
 
 
特权升级选项：
-s --sudo # 使用sudo (nopasswd)运行操作， 不推荐使用
-U --sudo-user=SUDO_USER # sudo 用户，默认为root， 不推荐使用
-S --su # 使用su运行操作 不推荐使用
-R --su-user=SU_USER # su 用户，默认为root，不推荐使用
-b --become # 运行操作
--become-method=BECOME_METHOD # 权限升级方法使用 ，默认为sudo，有效选择：sudo,su,pbrun,pfexec,runas,doas,dzdo
--become-user=BECOME_USER # 使用哪个用户运行，默认为root
--ask-sudo-pass # sudo密码，不推荐使用
--ask-su-pass # su密码，不推荐使用
-K --ask-become-pass # 权限提升密码
```

### ansible-doc

用于查看模块信息。

```shell
Usage: ansible <host-pattern> [options]

选项
-h --help # 显示此帮助信息
-l --list # 列出可用的模块
-s --snippet # 显示playbook制定模块的用法
-v --verbose # 详细模式（-vvv表示更多，-vvvv表示启用连接调试）
--version # 显示程序版本号
-M --module-path=MODULE_PATH # 指定模块库的路径


示例：
ansible-doc -l
ansible-doc shell
ansible-doc -s shell
```

### ansible-playbook

对于需反复执行的、较为复杂的任务，我们可以通过定义 Playbook 来搞定。它允许使用变量、条件、循环、以及模板，也能通过角色及包含指令来重用既有内容。

```shell
Usage: ansible-playbook playbook.yml

相对于ansible，增加了下列选项：
--flush-cache # 清除fact缓存
--syntax-check # 语法检查
--force-handlers # 如果任务失败，也要运行handlers
--list-tags # 列出所有可用的标签
--list-tasks # 列出将要执行的所有任务
--skip-tags=SKIP_TAGS # 跳过运行标记此标签的任务
--start-at-task=START_AT_TASK # 在此任务处开始运行
--step 一步一步：在运行之前确认每个任务
-t TAGS, --tags=TAGS 只运行标记此标签的任务
```


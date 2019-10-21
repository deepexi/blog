> Ansible 系列：
>
> - （一）：[快速上手 Ansible](./Ansible 快速上手.md)
> - （二）：[Ansible 命令](./Ansible 命令.md)
> - （三）：[Ansible 主机清单配置文件](./Ansible 主机配置清单.md)
> - （四）：[Ansible Playbook 剧本语法](./Playbook 剧本语法.md)

## Ansible Playbook 剧本语法

Playbook（剧本）是系统 Ansible 指令的集合，其利用 YAML 语言编写，自上而下按顺序一次执行。它可以实现一些 Ad-Hoc 指令无法实现的操作，例如从一台机器的文件中抓取内容并赋为另一台机器的变量等操作。

下面是一个 Playbook 剧本例子：

```yaml
---
- hosts: webservers
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: write the apache config file
    template: src=/srv/httpd.j2 dest=/etc/httpd.conf
    notify:
    - restart apache
  - name: ensure apache is running
    service: name=httpd state=started
  handlers:
    - name: restart apache
      service: name=httpd state=restarted
```

第一行中 `---` 是 YAML 将文件解释为正确文档的格式要求，YAML 它允许多个文档存在与同一个文件中，每个文档由 `---` 符号分割。通常一个 Playbook 对应一个文档，因此你也可以省略它。

YAML 具有强制性的格式规范，对空格非常敏感，通过空格来将不同信息分组在一起，而不能使用制表符，并且必须使用一致的间距才能正确读取文件。

以 `-` 开头的项目被视为列表项目，具有 key:value 格式的项。

YAML 文件的扩展名通常为 .yaml 或 .yml。

**Playbook 的执行结果有三种颜色：**

- 红色： 表示有task执行失败或者提醒的信息
- 黄色：表示执行了且改变了远程主机状态
- 绿色：表示执行成功

### Playbook 剧本语法

一个 Playbook 主要有以下四部分构成：

- **target section：**定义将要执行 playbook 的远程主机组；

- **variable section：**定义 playbook 运行时需要使用的变量；

- **task section：**定义将要在远程主机上执行的任务列表；

- **handler section：**定义task执行完成以后需要调用的任务；

#### Hosts（主机） 与 Users（用户）

每一个 Play 都要指定操作的目标主机，并且可以指定用哪个身份去完成执行的步骤（Tasks）。例如：

```yaml
- hosts: webservers
  remote_user: root
  tasks:
    - name: test connection
      remote_user: yourname
      sudo: yes
```

- hosts：用于指定要执行指定任务的主机，可以是一个或多个，由逗号分隔符分隔的主机组。
- remote_user：用于指定远程主机上执行任务的用户，它也可用于各tasks中。
- sudo：如果设置为 yes 则获取 root 权限去执行该任务，如果需要在使用 sudo 时指定密码，可在运行 `ansible-playbook` 命令时加上选项 `--ask-sudo-pass (-K)`。

- connection：通过什么方式连接到远程主机（默认 ssh）。
- gather_facts：默认会执行 setup 模块，设置该选项设置为 False 可以关闭自动执行 setup 模块。

#### vars (环境变量)

在执行 `ansible-playbook` 时通过添加选项  `--extra-vars` 看定义环境变量，可以在 Playbook 中定义，还可以在主机清单文件中配置。如果环境变量之间有冲突，则三者的优先级从高到低。

在 Playbook 中通过 `{{ var_name }}` 引用环境变量，如：

```yaml
- hosts: all
  vars:  
    file_name: test

  tasks:
  - name:
    file: path=/tmp/{{ file_name }} state=touch
```

#### register (注册变量)

通过 `register` 关键字可以存储指定命令的输出结果到一个自定义的变量中。

```yaml
- hosts: all
  tasks:
    - name:
      shell: netstat -lntp
      register: System_Status

    - name: Get System Status
      debug: msg={{System_Status.stdout_lines}}
```

#### tasks (任务)

每一个 Play 包含了一个 `tasks` 任务列表，任务列表中的任务会按次序逐个在指定的主机上执行，并且完成第一个后再开始第二个任务。

tasks 通过模块来完成实际操作，其格式为 `"module:options"`，除了 Command 和 Shell 模块之外，通常大多数模块使用 key=value 格式的参数。

```yaml
tasks:
 - name: make sure apache is running
   service: name=httpd state=running
   
tasks:
 - name: disable selinux
   command: /sbin/setenforce 0

tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_errors: True
```

#### when (条件语句)

Playbook 中的条件判断语句使用 `when`，通常这可以结合 Setup 模块针对不同系统主机执行不同的操作。

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: Create File
      file: path=/tmp/this_is_{{ ansible_hostname }}_file state=touch
      when: (ansible_hostname == "nfs") or (ansible_hostname == "backup")

#系统为centos的主机才会执行
    - name: Centos Install httpd
      yum: name=httpd state=present
      when: (ansible_distribution == "CentOS")

#系统为ubuntu的主机才会执行
    - name: Ubuntu Install httpd
      yum: name=httpd2 state=present
      when: (ansible_distribution == "Ubuntu")
```

#### with_items (循环语句)

除了条件语句之外，还可以使用循环语句 `with_items`，例如下面场景中通过循环语句批量安装软件：

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: Installed Pkg
      yum: name={{ item }} state=present
      with_items:
        - wget
        - tree
        - lrzsz
```

或者批量创建用户：

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: Add Users
      user: name={{ item.name }} groups={{ item.groups }} state=present
      with_items:
        - { name: 'testuser1', groups: 'bin' }
        - { name: 'testuser2', groups: 'root' }
```

#### ignore_errors (异常处理)

默认 Playbook 会检查命令和模块的返回状态，如遇到错误就中断执行。通过加入参数 `ignore_errors: yes` 来忽略错误。

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: Ignore False
      command: /bin/false
      ignore_errors: yes

    - name: touch new file
      file: path=/tmp/bgx_ignore state=touch
```

#### tags (标签)

通过对任务添加一个至多个标签，可以在执行 `ansible-playbook` 指令时使用 `-t` 或 `--skip-tags` 选项来控制执行指定标签任务，或跳过指定标签的任务。

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: Install Nfs Server
      yum: name=nfs-utils state=present
      tags:
        - install_nfs
        - install_nfs-server

    - name: Service Nfs Server
      service: name=nfs-server state=started enabled=yes
      tags: start_nfs-server
```

使用 `-t` 指定 `tags` 执行, 多个 `tags` 使用逗号隔开即可：

```shell
ansible-playbook -t install_nfs-server playbook.yml
```

#### handlers (触发回调)

我们还可以通过 `handlers` 在某个任务执行完成后触发某些操作，例如当一个文件内容被改动时，重启两个 services，如下面 Playbook：

```yaml
- hosts: all
  remote_user: root
  tasks:
    - name: template configuration file
      template: src=template.j2 dest=/etc/foo.conf
      notify:
         - restart memcached
         - restart apache
  handlers:
    - name: restart memcached
      service:  name=memcached state=restarted
    - name: restart apache
      service: name=apache state=restarted       
```

`notify` 下列出的即是 Handlers，Handlers 其实也是一些 tasks 的列表。

Handlers 是由通知者进行 `notify`，如果没有被 `notify`，Handlers 不会执行。

#### include (引入外部 Tasks 模块)

`include` 用来动态的包含 Tasks 任务列表。

```yaml
- hosts: all
  remote_user: root
  tasks:
    - include_tasks: p1.yml
    - include_tasks: p2.yml
```




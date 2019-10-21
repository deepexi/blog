> Ansible 系列：
>
> - （一）：[快速上手 Ansible](./Ansible 快速上手.md)
> - （二）：[Ansible 命令](./Ansible 命令.md)
> - （三）：[Ansible 主机清单配置文件](Ansible 主机配置清单.md)
> - （四）：[Ansible Playbook 剧本语法](Playbook 剧本语法.md)

## 快速上手 Ansible

Ansible 是  Paramiko 开发的一种自动化运维工具，基于模块化工作，集合了众多运维工具的优点，实现了批量系统配置，批量程序部署、批量运行命令等功能。

**Ansible 它本身没有批量部署的能力，真正执行这些操作的是 Ansible 的模块，它只是提供了一种框架。直到目前为止，Ansible 已有 800 多个模块可以使用。**

**Ansible 的另一个优势在于，它不需要在远程主机上安装任何东西，因为它是基于 SSH 来和远程主机进行通信的。**

### 安装 Ansible 

在 Ansible 里，有两种角色 Control Machine 与 Managed Node，它们通过 SSH 和 Python 进行沟通：

- **Control Machine（主控端）：**操作 Ansible 的机器，用于操纵 Managed Node
- **Managed Node（被控端）：**被 Ansible 操纵的机器

在一般情况下，**我们只需在 Control Machine 里安装 Ansible 即可**，因为 Linux 和 macOS 系统早已预载了 Python 2.5 以上的版本，且支持 SSH 连接。

而使用 Ansible 来管理 Window 的话，则需要较多的设置（此处不介绍，可自寻谷歌/百度）。

#### macOS 安装 Ansible

```shell
# 请先安装 homebrew，已安装者请略过
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# 安装 Ansible
brew install ansible
```

#### Linux 安装 Ansible

CentOS（Yum）

```shell
# 新增 epel-release 第三方套件来源。
sudo yum install -y epel-release
# 安装 Ansible
sudo yum install -y ansible
```

Ubuntu（Apt）

```shell
# 安装 add-apt-repository 必要套件
sudo apt-get install -y python-software-properties software-properties-common
# 使用 Ansible 官方的 PPA 套件来源
sudo add-apt-repository -y ppa:ansible/ansible; sudo apt-get update
# 安装 Ansible
sudo apt-get install -y ansible
```

#### 使用 Pip 安装 Ansible

```shell
# 1、首先安装 pip
# Debian, Ubuntu
$ sudo apt-get install -y python-pip
# CentOS
$ sudo yum install -y python-pip
# macOS
$ sudo easy_install pip

# 2、升级 pip
sudo pip install -U pip
# 3、安装 Ansible
sudo pip install ansible
```

### Ansible 文件

在安装 Ansible 之后，你可以访问以下 Ansible 文件：

- /usr/bin/ansible ：Ansible 命令行工具
- /usr/bin/ansible-doc ：Ansible 帮助文档工具
- /usr/bin/ansible-playbook ：Ansible 剧本执行工具
- /etc/ansible/ansible.cfg ：主配置文件
- /etc/ansible/hosts ：管理的主机清单
- /etc/ansible/roles ：角色存放处

###  Ansible 操作之 Ad-Hoc Command 和 Playbook

#### Ad-Hoc Commands

第一种方式是通过向 Ansible 发送 Ad-Hoc Commands（指令）来操作 Managed Node。

以常见的 `ping` 和 `echo` 操作为例：

- ping

  ```shell
  ansible all -m ping
  server1 | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }
  ```

- echo

  ```shell
  ansible all -m command -a "echo Hello World"
  server1 | SUCCESS | rc=0 >>
  Hello World
  ```

#### Playbook

另外一种方式即通过 Playbook （剧本）让各个 Managed Node 进行指定的动作（Plays）和任务（Tasks），你可以理解为 Shell Script。

Playbook 支持两种写法 ：

- **YAML：**简单易读
- **Jinja2：**模板化文件，支持变量、条件、循环语法

在一份 Playbook 中，可以有多个 Play、Task 与 Module：

- **Play：**目的
- **Task：**要执行的 Play 这个目的所需做的步骤
- **Module：**Ansible 所提供的模块来执行各种操作

下面是一个 Hello World 的 Playbook 剧本，剧本后缀名应为 .yml：

```yml
- name: say 'hello world'
  hosts: all
  tasks:

    - name: echo 'hello world'
      command: echo 'hello world'
      register: result

    - name: print stdout
      debug:
        msg: ""
```

执行剧本

```shell
ansible-playbook hello_world.yml
```

### 查看 Ansible 的 Modules

模块是 Ansible 的核心，也是操作真正的执行者，只要掌握了如何使用模块就可以快速上手 Ansible，其余都只是延伸使用罢了。   

例如我们经常使用的 **Command Modules 模块**，你可以进入 Ansible 的  [Module](http://docs.ansible.com/ansible/modules_by_category.html)  帮助文档中找到它的使用文档。

![automate_with_ansible_basic-20.jpg](https://chusiang.gitbooks.io/automate-with-ansible/content/imgs/automate_with_ansible_basic-20.jpg)

文档中 Options 选项表会列出模块参数，参数的预设值等信息。

![automate_with_ansible_basic-22.jpg](https://chusiang.gitbooks.io/automate-with-ansible/content/imgs/automate_with_ansible_basic-22.jpg)

### Setup 模块

在使用 Playbook 时，Ansible 会自动执行 [Setup Modules](http://docs.ansible.com/ansible/setup_module.html) 以收集各个 Managed Node 的 **facts（系统信息）**，如 IP、作业系统、CPU 信息等。

我们也可以通过 Ad-Hoc Commands 指令模式使用 setup，例如：

```shell
ansible all -m setup | less

--- 结果如下
server1 | SUCCESS => {
   "ansible_facts": {
       "ansible_all_ipv4_addresses": [
           "172.19.0.2"
       ],
       "ansible_all_ipv6_addresses": [
           "fe80::42:acff:fe13:2"
       ],
       "ansible_architecture": "x86_64",
       "ansible_bios_date": "03/14/2014",
:
```

通过 `filter` 参数还可以过滤结果

```shell
ansible all -m setup -a "filter=ansible_distribution*"

--- 结果如下
server1 | SUCCESS => {
   "ansible_facts": {
       "ansible_distribution": "Ubuntu",
       "ansible_distribution_major_version": "14",
       "ansible_distribution_release": "trusty",
       "ansible_distribution_version": "14.04"
   },
   "changed": false
}
```

通常在 Playbook 中我们会将主机信息结合条件判断 `when` 使用，例如下面针对  Debian, Ubuntu, CentOS 安装 Vim 的 playbook：

```shell
- name: Setup the vim 
 hosts: all
 become: true
 tasks:

   # Debian, Ubuntu.
   - name: install apt packages
     apt: name=vim state=present
     when: ansible_pkg_mgr == "apt"

   # CentOS.
   - name: install yum packages
     yum: name=vim-minimal state=present
     when: ansible_pkg_mgr == "yum"
```


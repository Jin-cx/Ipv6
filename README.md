# Ipv6
关于Ipv6代码
软件运行的开发语言为Delphi7，web服务器为IIS，操作系统是windows server2012
在将代码进行编译后，发布到本机服务器中进行功能校验，发布完成后只需要在web中输入localhost即可跳转到本机的主界面。以下为一些接口调试的一些步骤说明：
1、 New|Other|WebServices|SOAP Server Application|这里先选择建立Web App Debugger
    类型的WebService，因为这种类型的WebService便于调试，当我们调试好它，准备发布时再将
    此类型转换为ISAPI类型。
2、 选择Web App Debugger后，随便输入一个ClassName，这里我们输入“Test”
3、 随后Delphi会询问你是否建立接口单元，选择是，然后输入接口的名字，我们输入Main，
   Delphi将自动建立接口单元（名字为你输入的接口名+Intf结束，即MainIntf）和实现接口的单
   元（名字为你输入的接口名+Impl，即MainImpl）。到此一个空的WebService已建立好。
4、 接下来我们将编写供别人调用的WebService函数。在此我们编写一个简单的例子。打开接口单元
（MainIntf），在Type后，接口声明后添加接口函数
“function GetMsg(AMsg: string): String; stdcall;”，函数后面必须加上“stdcall”。
5、接口函数的声明已经完成，下面就是要实现这个函数了。打开接口实现单元（MainImpl），
   在public中写上该函数的声明，在implement后写该函数的实现。

6、到此，WebService已经撰写完毕。接下来是调试。在我们新建的时候，Delphi已经为我们
   建立了一个Unit1和其窗体，在Unit1中引用接口单元（MainImpl），然后在窗体中加一个
   按钮，在按钮的单击事件中调用刚才写的WebService函数就可以调试了，
7、调试成功后就可以转类型了，将Web App Debugger类型转换为ISAPI类型其实很简单，我们
   先重新建一个ISAPI类型的WebService项目，依次选择New|Other|WebServices|
   SOAP Server Application|ISPA/…，提示是否创建接口时选择“是”，然后输入和刚才一
   样的接口名，接着保存好，然后将调试成功的Web App Debugger类型的WebService项目中的
   接口单元和接口实现单元复制替换掉刚刚创建的ISAPI类型项目中的接口单元和接口实现单元，
   然后打开ISAPI类型的WebService，编译生成dll。至此ISAPI类型的WebService建立成功。

8、将ISAPI类型的WebService发布到IIS上。在IIS中新建站点，新建时将执行权限设置成“脚本
   和可执行文件”，将WebService整个项目拷贝到站点文件夹下，启动站点，该WebService就算
   发布成功了，如果IIS是6.0以上的注意在Web服务扩展中将“所有未知ISAPI扩展”设置为允许，
   具体设置可参见IIS帮助文档。


9、如何用Delphi调用刚才写的WebService。在浏览器中输入刚才站点的路径，如：
   http://192.168.1.5:90/，浏览器转到项目所在文件夹,

   点击bin，打开生成的dll文件夹，再点击生成的dll文件，打开如下图所示的的dll描述页面，
   该dll中有三个接口函数HZ，LJ，SaveData，它们都是供别人调用的接口函数。

   点击WSDL打开WSDL描述页面，此时复制该页面的网址，这个网址是我们要用到的。

10、 得到网址后，新建一个Application，我们就在这个Application中调用刚才的WebService。
     依次点击New|Other|WebServices|WSDL Import，如后提示输入网址，我们输入刚才复制的
     网址，点击next，finish，此时Delphi将自动添加一个单元，该单元就是调用WebService的
     单元，有了这个单元我们就可以调用WebService了。在Unit1中引用该单元，再添加一个按钮，
     在按钮的单击事件中声明一个接口对象，然后调用自动生成单元中的GetMainIntf（该方法是
     自动生成的）函数给这个接口对象赋值，然后就可以用这个接口对象调用接口函数了。

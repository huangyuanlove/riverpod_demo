# riverpod_demo

### 引入riverpod
demo中没有包含flutter_hook,所以我们选择引入flutter_riverpod即可
``` yaml
environment:
  sdk: ">=2.15.1 <3.0.0"
  flutter: ">=2.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^1.0.3
```

### hello world
首先，我们需要使用`ProviderScope`来包裹整个应用，也就是在main方法中
``` dart
void main() {
  runApp(ProviderScope(child: Home()));
}
```
然后我们可以声明一个Provider。一般情况下，我们会把各种各样的provider作为全局变量来引用，声明一个provider和声明一个函数没有多大的区别。
``` dart
final helloWorldProvider = Provider((_) => 'Hello world');
```
最后我们就可以读取Provider中的数据了。
在1.0.0之后的版本中，ConsumerWidget的build方法中提供了`WidgetRef`对象，用来取代0.14版本中的`useProvider`
``` dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final helloWorldProvider  = Provider((_)=>"hello world");

void main() {
  runApp(const ProviderScope(child: Home()));
}

class Home extends ConsumerWidget{
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final String value = ref.watch(helloWorldProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("riverpod demo"),),
        body: Center(
          child: Text(value),
        ),
      ),
    );
  }
}
```

###Provider

#### 各种各样的Provider
Provider
它只提供只读的数据
（只读的意思是，使用者不能在外部通过read直接修改数据）
使用场景：数据类型A只能根据若干可观察对象计算生成
例子：如果需要持续观察三个人的最高得分（有三个ProviderBase提供了三个人的得分）可以建立一个Provider来观察这三个人的得分，对外提供最大值。
StateProvider
对外提供可读可写的数据
使用场景：数据类型A可以被任意方式赋值
例子：由于对修改不存在限制，那么很可能会由于不安全的操作导致异常，比如null指针，所以除非是可以确保修改者的操作一定是安全的或简单的（比如counter demo），否则都不建议使用此类。
StateNotifierProvider
提供可读的StateNotifier，这是一种在提供者中确保数据安全的类
使用场景：数据类型A可以被外部修改，但修改方式是有限的
例子：
ChangeNotifierProvider
提供可读的ChangeNotifier
使用场景：有一组数据可以被外部修改，但修改方式是有限的
例子：MVVM中的VM
FutureProvider
提供只读的数据，loading，error状态
使用场景：观察产生一个结果的异步操作的过程和结果
例子：数据A获取过程中，显示一个loading状态
StreamProvider
提供只读的数据，loading，error状态
使用场景：观察产生若干结果的异步操作的过程和结果
例子：获取若干数据类型A，并在获取到第一个之前显示一个loading状态
ScopedProvider
提供以特殊方式可写的数据
使用场景：如果一个提供者，在树中若干位置可用，且他们需要特殊的值在他们所在子树中生效
例子：它可以以注入的方式给list的item注入数据，而避免写构造函数，官方的例子非常棒！

#### Provider的修饰符
.family
.autoDispose

### WidgetRef

#### 获取WidgetRef对象


这里的`WidgetRef`对象在读取Provider中的数据时，提供了`read`、`listen`和`watch`方法。至于什么情况下选用哪个方法，这里有三个建议
> * 当我们需要监听变化并且从Provider中获取数据时，比如当数据变化时我们需要重新构建Widget，这时我们可以使用`ref.watch`
> * 当我们需要监听变化去执行某个动作时，我们可以使用`ref.listen`
> * 当我们仅需要读取数据不关心数据的变化时，比如点击某个按钮时，根据状态来判断下一步动作时，我们可以使用`ref.read`

#### WidgetRef对象的方法

* ref.watch
``` dart
final counterProvider = StateProvider((_)=> 0);
class Home extends ConsumerWidget{
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int count = ref.watch(counterProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("riverpod demo"),),
        body: Center(
          child: Column(
            children: [
              Text('$count')
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: ()=>{
          ref.read(counterProvider.state).state++
        },child: const Text("点击"),),
      ),
    );
  }
}
```
* ref.read

* ref.listen

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

### Provider

#### 各种各样的Provider
##### Provider
它只提供只读的数据
（只读的意思是，使用者不能在外部通过read直接修改数据）
使用场景：数据类型A只能根据若干可观察对象计算生成
例子：如果需要持续观察三个人的最高得分（有三个ProviderBase提供了三个人的得分）可以建立一个Provider来观察这三个人的得分，对外提供最大值。
##### StateProvider
对外提供可读可写的数据
使用场景：数据类型A可以被任意方式赋值
例子：由于对修改不存在限制，那么很可能会由于不安全的操作导致异常，比如null指针，所以除非是可以确保修改者的操作一定是安全的或简单的（比如counter demo），否则都不建议使用此类。
##### StateNotifierProvider
提供可读的StateNotifier，这是一种在提供者中确保数据安全的类
使用场景：数据类型A可以被外部修改，但修改方式是有限的
例子：
##### ChangeNotifierProvider
提供可读的ChangeNotifier
使用场景：有一组数据可以被外部修改，但修改方式是有限的
例子：MVVM中的VM
##### FutureProvider
提供只读的数据，loading，error状态
使用场景：观察产生一个结果的异步操作的过程和结果
例子：数据A获取过程中，显示一个loading状态

##### StreamProvider
提供只读的数据，loading，error状态
使用场景：观察产生若干结果的异步操作的过程和结果
例子：获取若干数据类型A，并在获取到第一个之前显示一个loading状态
##### ScopedProvider
提供以特殊方式可写的数据
使用场景：如果一个提供者，在树中若干位置可用，且他们需要特殊的值在他们所在子树中生效
例子：它可以以注入的方式给list的item注入数据，而避免写构造函数，官方的例子非常棒！

#### Provider的修饰符
##### .family

该修饰符适用于适用外部数据来构建provider的情况

一些常用情况

* 和[FutureProvider](https://pub.dev/documentation/riverpod/latest/riverpod/FutureProvider-class.html) 组合，来根据id获取消息
* 把当前Locale对象传给provider，用来进行国际化
* 在不访问对方属性的前提下连接两个provider

在使用family时，会额外的向provider提供一个属性，在provider中我们可以自由的使用该属性来创建某些状态

``` dart
final messagesFamily = FutureProvider.family<Message, String>((ref, id) async {
  return dio.get('http://my_api.dev/messages/$id');
});
```

这种情况下在使用`messagesFamily`时会有点语法上的变化，我们需要额外提供一个参数

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  final response = ref.watch(messagesFamily('id'));
}
```

它还支持同时获取不同的属性

``` dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final frenchTitle = ref.watch(titleFamily(const Locale('fr')));
  final englishTitle = ref.watch(titleFamily(const Locale('en')));

  return Text('fr: $frenchTitle en: $englishTitle');
}
```





##### .autoDispose

### WidgetRef

#### 获取WidgetRef对象

##### 从其他Provider对象中获取

``` dart
final provider = Provider((ref) {
  // use ref to obtain other providers
  final repository = ref.watch(repositoryProvider);
  return SomeValue(repository);
})
```

`ref`对象可以很安全的在provider之间传递，一个常见的用法就是讲`ref`传递给 [StateNotifier](https://pub.dev/documentation/state_notifier/latest/state_notifier/StateNotifier-class.html)

``` dart
final counter = StateNotifierProvider<Counter, int>((ref) {
  return Counter(ref);
});

class Counter extends StateNotifier<int> {
  Counter(this.ref): super(0);

  final Ref ref;

  void increment() {
    // Counter can use the "ref" to read other providers
    final repository = ref.read(repositoryProvider);
    repository.post('...');
  }
}
```

这么做可以让Counter内部读取provider状态

##### 从Widget对象中获取ref

一般情况下Widget对象中是没有ref对象中，但riverpod提供了几种解决方案

* 使用ConsumerWidget替换StatelessWidget

ConsumerWidget和StatelessWidget基本相同(虽然是继承了StatefulWidget)，只是在build方法中多了一个WidgetRef对象

``` dart
class HomeView extends ConsumerWidget {
  const HomeView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // use ref to listen to a provider
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}
```

* 使用ConsumerStatefulWidget+ConsumerState 替换 StatefulWidget+State

``` dart
class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}): super(key: key);

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
    ref.read(counterProvider);
  }

  @override
  Widget build(BuildContext context) {
    // We can also use "ref" to listen to a provider inside the build method
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}

```

* 使用 HookConsumerWidget 替换 HookWidget

``` dart
class HomeView extends HookConsumerWidget {
  const HomeView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HookConsumerWidget allows using hooks inside the build method
    final state = useState(0);

    // We can also use the ref parameter to listen to providers.
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}
```





#### WidgetRef对象的方法


这里的`WidgetRef`对象在读取Provider中的数据时，提供了`read`、`listen`和`watch`方法。至于什么情况下选用哪个方法，这里有三个建议
> * 当我们需要监听变化并且从Provider中获取数据时，比如当数据变化时我们需要重新构建Widget，这时我们可以使用`ref.watch`
> * 当我们需要监听变化去执行某个动作时，我们可以使用`ref.listen`
> * 当我们仅需要读取数据不关心数据的变化时，比如点击某个按钮时，根据状态来判断下一步动作时，我们可以使用`ref.read`



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

使用该方法可以没有任何影响的获取一次provider的状态，但是作者提示我们尽量不要使用该方法，它只是用来解决使用`watch|listen`不方便的问题，如果可以，尽量使用`watch|listen.`这里有个使用read方法的示例https://riverpod.dev/docs/concepts/combining_providers#can-i-read-a-provider-without-listening-to-it

``` dart
final counterProvider = StateNotifierProvider<Counter, int>((ref) => Counter());

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Call `increment()` on the `Counter` class
          ref.read(counterProvider.notifier).increment();
        },
      ),
    );
  }
}
```



* ref.listen

和`ref.watch`相似，我们也可以使用`ref.listen`来观察provider。他们的区别就是当provider状态变化时，我们可以调用自己定义的方法。该方法需要两个参数，第一个参数是要监听的provider对象，第二个参数是回调方法，

``` dart
final counterProvider = StateNotifierProvider<Counter, int>((ref) => Counter());

final anotherProvider = Provider((ref) {
  ref.listen<int>(counterProvider, (int? previousCount, int newCount) {
    print('The counter changed ${newCount}');
  });
  ...
});
```

或者

``` dart
final counterProvider = StateNotifierProvider<Counter, int>((ref) => Counter());

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(counterProvider, (int? previousCount, int newCount) {
      print('The counter changed ${newCount}');
    });
    ...
  }
}
```

#### 决定订阅什么

比如我们有一个StreamProvider

``` dart
final userProvider = StreamProvider<User>(...);
```

我们可以这么去订阅

* 通过监听provider本身来同步获取当前状态

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  AsyncValue<User> user = ref.watch(userProvider);

  return user.when(
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => const Text('Oops'),
    data: (user) => Text(user.name),
  );
}
```

* 通过监听`userProvider.stream`来获取对应的stream

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  Stream<User> user = ref.watch(userProvider.stream);
}
```

* 通过监听`userProvider.future`来获取一个能得到最新状态的Future

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  Future<User> user = ref.watch(userProvider.future);
}
```

#### 使用"select" 来决定哪些值变化时进行重建

比如我们有一个User对象

``` dart
abstract class User {
  String get name;
  int get age;
}
```

但是我们在渲染页面时只用到了name属性

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  User user = ref.watch(userProvider);
  return Text(user.name);
}
```

这种情况下，如果`age`属性发生了变化，该Widget就会重建，显然这不是我们想要的。这时候我们可以使用`select`来选择对象的某些属性来监听

``` dart
Widget build(BuildContext context, WidgetRef ref) {
  String name = ref.watch(userProvider.select((user) => user.name))
  return Text(name);
}
```

当然，`select`同样适用于`listen`方法

``` dart
ref.listen<String>(
  userProvider.select((user) => user.name),
  (String? previousName, String newName) {
    print('The user name changed $newName');
  }
);
```

需要注意的是，这里没必要一定返回对象的属性，只要复写了`==`的值都可以正常工作，比如

``` dart
final label = ref.watch(userProvider.select((user) => 'Mr ${user.name}'));
```




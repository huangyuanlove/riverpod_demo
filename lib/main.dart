import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final helloWorldProvider  = Provider((_)=>"hello world");
final counterProvider = StateProvider((_)

class Home extends ConsumerWidget{
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final String value = ref.watch(helloWorldProvider);
    final int count = ref.watch(counterProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("riverpod demo"),),
        body: Center(
          child: Column(
            children: [
              Text(value),
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

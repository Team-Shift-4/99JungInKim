# Kotlin 소개

## Kotlin의 등장 배경

Kotlindms JetBrains에서 Opensource Group을 만들어 개발한 Progamming 언어
2011년 처음 공개되었으며 2017년 Google에서 Android 공식 Language로 지정해 유명해 짐
Java의 이름이 섬에서 따왔기에 대체하는 Kotlin 역시 섬 이름

Kotlin으로 Android App을 개발할 수 있는 이유는 JVM-Based Language이기 때문
Kotlin Source -- Kotlin Compiler(Kotlinc) -> Java Byte Code ---> JVM
확장자가 .kt인 파일을 Kotlinc가 Compile할 시 Java Byte Code가 만들어 짐

### Kotlin의 이점

- Expressive & Concise(표현력과 간결함)
- Safer Code(안전한 코드)
  - NullPointException을 Compiler 단에서 제어할 수 있음(Null Safety)
- Interoperable(상호 운용성)
  - Kotlin은 Java와 100% 호환
    - Java Class나 Library를 활용할 수 있음(역으로도 가능)
    - Java와 Kotlin을 혼용 가능
- Structured Concurrency(구조화 동시성)
  - Coroutines이라는 기법으로 비동기 프로그래밍을 간소화 가능
  - Network 연동이나 DB 갱신 등의 작업시 유용하고 효율적

### Kotlin File Structure

Kotlin File의 확장자는 `.kt`
예시

```kotlin
package com.example.test

import java.text.SimpleDateFormat
import java.util.*

var data = 10

fun formatData(date: Date): String {
    val sdformat = SimpleDateFormat("yyyy-mm-dd")
    return sdformat.format(date)
}

class User {
    var name = "Jungin Kim"
    
    fun sayHello() {
        println("Hello $name!")
    }
}
```

Package 구문은 이 File을 Compile했을 때 만들어지는 Class File의 위치를 나타냄
Source File의 첫 줄에 한 줄로 선언
이 File의 Class File은 `com/example/test` Folder에 생성
Package 이름은 Kotlin File의 위치와 상관없는 별도의 이름으로 선언 가능

Import 구문은 Package 아래에서 여러 줄 작성 가능

Variable, Function, Class는 Import 구문 아래에 여러 개를 선언할 수 있음
Variable과 Function은 Class 안 뿐만 아니라 밖에도 선언할 수 있음

추가적으로 같은 Package로 선언할 시 Import 없이 사용 가능

```kotlin
package com.example.test

import java.util.*

fun main() {
    data = 20
    formatDate(Date())
    User().sayHello()
}
```

다른 Package일 시 Import로 사용 가능

```kotlin
package com.example.test2

import com.example.test.User
import com.example.test.data
import com.example.test.formatDate

import java.util.*

fun main() {
    data = 20
    formatDate(Date())
    User().sayHello()
}
```

# Variable & Function

### Variable 선언

Kotlin에서 Variable은 `val`, `var` Keyword로 선언
`val`: Value(상수, 변할 수 없는 변수), `var`: Variable(변수, 변할 수 있는 변수)

```kotlin
val test: Int = 10
var test2 = 20		// Type 추론이 가능할 시 생략할 수 있음
```

초기 값을 맨 처음에 할당하지 않고 이후 할당할 시 `lateinit`, `lazy` Keyword를 이용
`lateinit`: 이후 초기 값을 할당할 것임을 명시적으로 선언, `lazy`: 변수 선언 문 뒤 `by lazy{}`형식으로 선언해 계산 값이 할당

```kotlin
lateinit var data1: Int		// Error
lateinit val data2: String	// Error
lateinit var data3: String	// Success
```

`lateinit`의 경우 `var`에서만 사용할 수 있으며 Int, Long, Short, Double, Float, Boolean, Byte Type에서 사용 불가

```kotlin
val data4: Int by lazy {
    println("lazy")
    10
}
fun main() {
    println("main")
    println(data + 10)
    println(data + 10)
}
```

### Data Type

Kotlin의 모든 Variable = Object

정수를 다루는 Type = Int인데 Int는 Primitive Type이 아니라 Object

```kotlin
fun test() {
    var data1: Int = 10
    var data2: Int? = null		// null 대입 가능
    
    data1 = data1 + 10
    data1 = data1.plus(10)		// Object의 Method 이용 가능
}
```

위 Source는 `data1`과 `data2`를 Int Type으로 선언
만약 Int Type이 Primitive Type이라면 null 대입이 불가하며 Method 호출 불가
Kotlin의 모든 Type은 Object이므로 Int Type에 10과 Null을 대입할 수도 Method도 호출 할 수 있음

#### Int, Short, Long, Double, Float, Byte, Boolean - Primitive Type Object

기초 데이터를 객체로 표현하는 Type

Int, Short, Long: 정수, Double, Float: 실수, Byte: 2진수, Boolean: 참 거짓

```kotlin
val a1: Byte = 0b00101011
val a2: Int = 123
val a3: Short = 123
val a4: Long = 10L
val a5: Double = 10.0
val a6: Float = 10.0f
val a7: Boolean = true
```

#### Char, String - 문자와 문자열

Char Type은 문자를 표현, Kotlin에서는 `'`로 감싸 표현하며 Number Type으로 표현 불가

String Type은 문자열 표현, Kotlin에서는 `"""`이나 `"`로 표현하며 `"""`는 줄바꿈이나 들여쓰기 등을 유지함
참고로 Android Studio에서 `"""`를 사용하면 닫는 따옴표 뒤 `.trimIndent()` Function이 자동으로 추가됨(문자열 앞 공백 제거)

String Type의 데이터나 Variable이나 연산 결과 값을 포함할 때 `$`기호를 사용하며 이를 문자열 템플릿이라 함

```kotlin
fun main() {
    fun sum(no: Int): Int {
        var sum = 0
        for (i in 1..no) {
            sum += i
        }
        return sum
    }
    val name: String = "Jungin Kim"
    println("name: $name, sum: ${sum(10)}, plus: ${10 + 20}")
}
```

함수의 매개 변수는 항상 `val`이 자동으로 적용되며 함수 안에서 매개변수 값을 변경할 수 없음
`var`, `val` Keyword 사용하지 않음

함수 매개변수에 기본값을 선언할 수 있으며 선언했을 시 호출 시 인자를 전달하지 않아도 되며 명시한 기본 값이 적용

```kotlin
fun main() {
    fun mul(data1: Int, data2: Int = 10): Int {
        return data1 * data2
    }
    println(mul(10))
    println(mul(10, 20))
}
```

어떤 변수의 매개변수가 여러개면 호출할 때 전달한 인자 순대로 할당하나 매개변수 명을 지정해 자유롭게 호출할 수 있음

```kotlin
fun main() {
    fun mul(data1: Int, data2: Int = 10): Int {
        return data1 * data2
    }
    println(mul(10))
    println(mul(data2 = 10, data1 = 20))
}
```

## Collection Type

여러 Data를 표현하는 Type이며 Array, List, Set, Map이 있음

### Array - 배열

접근 시 대괄호, get, set 사용 가능

```kotlin
<init>(size: Int, init: (Int) -> T)

val data1: Array<Int> = Array(3, {0})
val data2 = arrayOf<Int>(10, 20, 30)

println("data1: ${data1[0]}, ${data1[1]}, ${data1.get(2)}")
```

기초 Type은 BooleanArray, ByteArray, CharArray, DoubleArray, FloatArray, IntArray, LongArray, ShortArray 로도 이용 가능하며 arrayOf()도 가능

```
val data1: IntArray = Array(3, {0})
val data2 = intArrayOf<Int>(10, 20, 30)
```

### List, Set, MAp

Collection Interface를 Type으로 표현한 Class이며 모두 Collection Type이라고 부름

-   List: 순서 있는 Data Set, 중복 허용, 불변
-   MutableList: 순서 있는 Data Set, 중복 허용, 가변
-   Set: 순서 없는 Data Set, 중복 미허용, 불변
-   MutableSet: 순서 없는 Data Set, 중복 미허용, 가변
-   Map: Key-Value Data Set, Key 중복 미허용, 불변
-   MutableMap: Key-Value Data Set, Key 중복 미허용, 가변

가변은 `add()`, `set()`, `size()`, `get()` 가능하나 불변은 `size()`, `get()` 불가

생성할 땐 `Type` + `Of<Data Type>`과 같으 ㄴ형식으로 생성 가능

```kotlin
fun main() {
    var list = listOf<Int>(10, 20, 30)
    var muList = mutableListOf<Int>(10, 20, 30)
    mutableList.add(3, 40)
    var map = mapOf<String, String>(Pair("1", "one"), "2" to "two")
}
```

# 조건문과 반복문

## if, else if, else

원래의 if, else if, else와 크게 다르지않으나 표현식으로도 사용할 수 있다는 특이점이 있음

```kotlin
fun main() {
    var data = 10
    var result = if (data > 0) {
        printf("data > 0")
        true
    } else {
        printf("data <= 0")
        false
    }
}
```

## when

c언어의 Switch - case문과 같으나 다양한 유형의 조건을 제시할 수 있음이 차이이며 데이터 명시 없이 사용할 수 있으며 표현식으로 사용할 수 있음

```kotlin
fun main {
    var data: Any = "hi"
    when (data) {
        "hi" -> println("hello")
        "bye" -> println("goodbye")
        else -> {
            println("unknown")
        }
    }
    when (data) {
        is String -> println("hello")
        20, 30 -> println("goodbye")
        in 1..10 -> println("good afternoon")
        else -> {
            println("unknown")
        }
    }
    when {
        data == "hi" -> printf("hello")
        else -> {
            printf("goodbye")
        }
    }
    val result = when {
        data == "hi" -> "hello"
        else -> "goodbye"
    }
}
```

## for & while

for문의 조건은 주로 범위 연산자이며 while문은 조건이 참이면 실행 거짓이면 넘어감

```kotlin
for(i in 1..10)							// 1~10까지 1씩
for(i in1 until 10)						// 1~9까지 1씩
for(i in 2..10 step 2)					// 2~10까지 2씩
for(i in 10 downTo 1)					// 10~1까지 -1씩
for(i in data.indices)					// data의 개수 만큼
for((index, value) in data.withIndex())	// Index와 value를 가져옴
while(<조건>)							   // 조건이 참인 동안
```

# Class 와 생성자

Class는 `class`로, 생성자는 `constructor` Keyword로 선언

```kotlin
class User { 
	var name = "Jungin Kim"
    constructor(name: String) {
        this.name = name
    }
    fun printName() {
        println("name: $name")
    }
    class SUser { }
}
```

## 주 생성자와 보조 생성자

### 주 생성자

주 생성자는 `constructor` Keyword로 Class 선언부에 선언
필수는 아니며 한 Class에 하나만 가능하며 Keyword 생략 가능
주 생성자를 선언하지 않을 시 Compiler는 매개 변수가 없는 주 생성자를 자동으로 추가하며 필요에 따라 매개 변수를 선언할 수 있음
`init` Keyword를 사용해 객체 생성시 자동으로 생성자를 실행시킬 수 있음

```kotlin
class User constructor() {}				// 매개 변수가 없는 주 생성자
class User() {}							// 매개 변수가 없는 주 생성자, constructor 생략 가능
class User {}							// 매개 변수가 없는 주 생성자, constructor와 괄호 생략 가능
class User(name: String, count: Int) {}	// 매개 변수가 있는 주 생성자

class User() {
    init {} // 주 생성자
}

class User(name: String, count: Int) {
    init {
        println("name: $name")	// 성공
    }
    fun printName() {
        println("name: $name")	// 실패
    }
}

class User(name: String, count: Int) {
    var name: String
    var count: Int
    init {						// Class Member Variable Constructor Paraemter 값 대입
        this.name = name
        this.count = count
    }
    fun printName() {
        println("name: $name")	// 성공
    }
}

class User(val name: String, val count: Int) {	// 주 생성자에서만 유일하게 var나 val keyword로 매개변수를 선언할 수 있음
    fun printName() {
        println("name: $name")	// 성공
    }
}
```

### 보조 생성자

Class의 본문에 `constructor` Keyword로 선언하며 여러 개 생성할 수 있음

```kotlin
class User {
    constructor(name: String) {
        println("name: $name")
    }
    constructor(name: String, count: Int) {
        println("name: $name, count: $count")
    }
}
```

### 보조 생성자에 주 생성자 연결

Class 선언 시 둘 중 하나만 선언하면 문제가 없으나 둘 다 선언할 시 생성자끼리 연결해줘야 함

```kotlin
class User(name: String) {
    constructor(name: String, count: Int) this(name) {} // this()를 사용해 주 생성자 호출 후 작동
}

class User(name: String) {
    constructor(name: String, count: Int) this(name) {} // this()를 사용해 주 생성자 호출 후 작동
    constructor(name: String, count: Int, email: String) this(name, count) {} // this()를 사용해 보조 생성자 호출 후 작동
}
```

# Class 재사용하는 상속

## 상속과 생성자

Class 선언 시 다른 Class를 참조해 선언하는 것을 상속이라 함
선언부 `:`과 함께 상속 받을 Class 이름을 입력
상속 대상은 상속할 수 있게 `open` Keyword를 앞에 붙임

```kotlin
open class Kim {}
class Jungin: Kim() {}

open class Kim(name: String) {}
class JunginL Kim {
    constructor(name: String): super(name) {}
}
```

## 오버라이딩

상속의 장점은 하위 클래스에서 상의 클래스에 정의된 멤버를 자신의 것처럼 사용할 수 있다는 점

```kotlin
open class Super {
    var data = 10
    fun printData() {
        println("Super: $data")
    }
}
class Sub: Super()
fun main() {
    val obj = Sub()
    obj.data = 20
    obj.printData()
}

open class Super {
    open var data = 10
    open fun printData() {
        println("Super: $data")		// 실행되지 않음
    }
}
class Sub: Super() {
    override var data = 20
    override fun printData() {
        println("Sub: $data")		// 실행
    }
}
fun main() {
    val obj = Sub()
    obj.printData()
}
```

## 접근 제한자

| 접근 제한자     | 최상위에서 사용            | 클래스 멤버에서 사용                    |
| --------------- | -------------------------- | --------------------------------------- |
| public(Default) | 모든 파일에서 접근 가능    | 모든 클래스에서 접근 가능               |
| internal        | 같은 모듈 내에서 접근 가능 | 같은 모듈 내에서 접근가능               |
| protected       | 접근 불가                  | 상속 관계의 하위 클래스에서만 접근 가능 |
| private         | 파일 내부에서만 접근 가능  | 클래스 내부에서만 접근 가능             |

```kotlin
open class Super {
    var publicData = 1
    protected var protectedData = 2
    private var privateData = 3
}
class Sub: Super() {
    fun subFun() {
        publicData++		// 성공
        protectedData++		// 성공
        privateData++		// 실패
    }
}
fun main() {
    val obj = Super()
    obj.publicData++		// 성공
    obj.protectedData++		// 실패
    obj.privateData++		// 실패
}
```

# Class 종류

## Data Class

`data` Keyword로 선언하며 VO Class를 편리하게 이용할 수 있게 해줌

```kotlin
class NonDataClass(val name: String, val email: String, val age: Int)
data class DataClass(val name: String, val email: String, val age: Int)
```

VO Class는 Data를 주요하게 다루며 서로 같은지 비교 연산할 때가 잦음
Object의 Data가 같은 지 검사할 땐 `equals()` 함수를 이용

```kotlin
fun main(){
    val non1 = NonDataClass("Jungin", "Jungin@icloud.com", 25)
    val non2 = NonDataClass("Jungin", "Jungin@icloud.com", 25)
    val data1 = DataClass("Jungin", "Jungin@icloud.com", 25)
    val data2 = DataClass("Jungin", "Jungin@icloud.com", 25)
    if(non1.equals(non2)) {
        println("non is same")		// 미실행
    }
    if(data1.equals(data2)) {
        println("data is same")		// 실행
    }
}
```

`equals()` 함수는 주 생성자에 선언한 멤버 변수의 데이터만 비교

```kotlin
data class DataClass(val name: String) {
    lateinit val email: String
    lateinit val age: Int
    constructor(name: String, email: String, age: Int):
    this(name, email, age) {
        this.email = email
        this.age = age
    }
}

fun main() {
    val obj1 = DataClass("Jungin", "Jungin@icloud.com", 25)
    val obj2 = DataClass("Jungin", "JunginKim@icloud.com", 24)
    if(obj1.equals(obj2)) {
        println("same")	// 실행
    }
}
```

Object의 Data를 반환하는 `toString()` 함수

```
fun main() {
    val data = DataClass("Jungin", "Jungin@icloud.com", 25)
    println("data toString: ${data.toString}")	
    // data toString: DataClass(name=Jungin, email=Jungin@icloud.com, age=25)
}
```

## Object Class

Anonymous Class를 만들 목적으로 사용, `object` Keyword를 사용

```kotlin
open class Super {
    open var data = 10
    open fun printFun() {
        println("super: $data")		// 실행하지 않음
    }
}
val obj = object {
    var data = 10
    fun printFun() {
        println("data: $data")
    }
}
val obj2 = object: Super() {
    override var data = 10
    override fun printFun() {
        println("data: $data")		// 실행
    }
}
fun main() {
    obj.data = 20		// 오류
    obj.printFun()		// 오류
    obj2.data = 20		// 실행
    obj2.printFun()		// 실행
}
```

## Companion

Member Variable나 Function를 Class 이름으로 접근할 때 사용, `companion` Keyword를 사용

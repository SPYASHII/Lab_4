:- use_module(library(strings)). % Для роботи з рядками
:- use_module(library(lists)).  % Для роботи зі списками

% Генерація алфавіту
alphabet_power(N, Alphabet) :-
    findall(Char, (between(1, N, I), char_code('A', Code), CharCode is Code + I - 1, char_code(Char, CharCode)), Alphabet).

% Читання чисел із рядка
read_numbers(Numbers) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " ", "", NumStrings),
    findall(Number, (member(Str, NumStrings), number_string(Number, Str)), Numbers).

% Сортування чисел
sorted_numbers(Numbers, Sorted) :-
    sort(Numbers, Sorted).

% Обчислення інтервалів
intervals(N, Min, Max, Intervals) :-
    (   Min =:= Max
    ->  Intervals = [[Min, Max]]
    ;   Range is Max - Min,
        Step is Range / N,
        UpperBound is N - 1,
        findall([A, B], (between(0, UpperBound, I), A is Min + I*Step, B is Min + (I+1)*Step), Intervals)
    ).

% Присвоєння літери числу з коректною обробкою верхньої межі
assign_letter(Number, Intervals, Alphabet, Letter) :-
    nth0(Index, Intervals, [A, B]),
    Number >= A - 0.0001, % Додано допуск для нижньої межі
    length(Intervals, Len),
    LastIndex is Len - 1,
    (   Index =:= LastIndex  % Останній інтервал включає верхню межу
    ->  Number =< B + 0.0001
    ;   Number < B + 0.0001
    ),
    nth0(Index, Alphabet, Letter).

% Формування послідовності літер з відлагодженням
linguistic_sequence(Numbers, Intervals, Alphabet, Sequence) :-
    maplist(assign_letter_with_debug(Intervals, Alphabet), Numbers, Sequence).

% Допоміжний предикат для відлагодження
assign_letter_with_debug(Intervals, Alphabet, Number, Letter) :-
    assign_letter(Number, Intervals, Alphabet, Letter).

% Побудова матриці переходів
transition_matrix(Sequence, Alphabet, Matrix) :-
    (   Sequence = []
    ->  Matrix = []
    ;   findall(Row, (member(From, Alphabet), findall(Count, (member(To, Alphabet), transitions(Sequence, From, To, Count)), Row)), Matrix)
    ).

% Підрахунок переходів між літерами
transitions(Sequence, From, To, Count) :-
    findall(1, (nextto(From, To, Sequence)), Ones),
    length(Ones, Count).

% Основний предикат із налагодженням
main :-
    write('Введіть потужність алфавіту: '),
    read_line_to_string(user_input, NStr),
    (   number_string(N, NStr), integer(N), N > 0
    ->  write('Потужність алфавіту: '), write(N), nl,
        alphabet_power(N, Alphabet),
        write('Введіть числовий ряд одним рядком (числа розділені пробілами): '),
        read_numbers(Numbers),
        write('Введені числа: '), write(Numbers), nl,
        sorted_numbers(Numbers, Sorted),
        (   Sorted = []
        ->  write('Помилка: не введено жодного числа'), nl, fail
        ;   [Min|_] = Sorted,
            reverse(Sorted, [Max|_]),
            write('Min: '), write(Min), write(', Max: '), write(Max), nl,
            intervals(N, Min, Max, Intervals),
            write('Інтервали: '), write(Intervals), nl,
            linguistic_sequence(Numbers, Intervals, Alphabet, Sequence),
            write('Послідовність літер: '), write(Sequence), nl,
            (   Sequence = []
            ->  write('Помилка: не вдалося сформувати послідовність літер'), nl, fail
            ;   atomic_list_concat(Sequence, LinguisticString),
                write('Лінгвістичний ряд: '), write(LinguisticString), nl,
                transition_matrix(Sequence, Alphabet, Matrix),
                write('Сформована матриця: '), write(Matrix), nl,
                (   Matrix = []
                ->  write('Помилка: матриця переходів порожня'), nl, fail
                ;   write('Матриця переходів:'), nl,
                    print_matrix(Matrix, Alphabet)
                )
            )
        )
    ;   write('Помилка: потужність алфавіту має бути додатним цілим числом'), nl, fail
    ).

% Виведення матриці у зрозумілому форматі
print_matrix(Matrix, Alphabet) :-
    write('  '), maplist(write, Alphabet), nl,
    length(Alphabet, Len),
    length(Indices, Len),
    maplist(=(0), Indices), % Створюємо список індексів [0,0,...,0]
    maplist(print_row(Alphabet), Matrix, Indices).

% Виведення рядка матриці
print_row(Alphabet, Row, Index) :-
    nth0(Index, Alphabet, Char),
    write(Char), write(' '),
    maplist(write_with_space, Row), nl,
    NextIndex is Index + 1.

% Допоміжний предикат для виведення чисел із пробілом
write_with_space(Num) :-
    write(Num), write(' ').
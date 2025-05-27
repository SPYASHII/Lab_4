:- use_module(library(strings)). % ��� ������ � �������
:- use_module(library(lists)).  % ��� ������ � ��������

% ��������� �������
alphabet_power(N, Alphabet) :-
    findall(Char, (between(1, N, I), char_code('A', Code), CharCode is Code + I - 1, char_code(Char, CharCode)), Alphabet).

% ������� ����� �� �����
read_numbers(Numbers) :-
    read_line_to_string(user_input, Line),
    split_string(Line, " ", "", NumStrings),
    findall(Number, (member(Str, NumStrings), number_string(Number, Str)), Numbers).

% ���������� �����
sorted_numbers(Numbers, Sorted) :-
    sort(Numbers, Sorted).

% ���������� ���������
intervals(N, Min, Max, Intervals) :-
    (   Min =:= Max
    ->  Intervals = [[Min, Max]]
    ;   Range is Max - Min,
        Step is Range / N,
        UpperBound is N - 1,
        findall([A, B], (between(0, UpperBound, I), A is Min + I*Step, B is Min + (I+1)*Step), Intervals)
    ).

% ��������� ����� ����� � ��������� �������� ������� ���
assign_letter(Number, Intervals, Alphabet, Letter) :-
    nth0(Index, Intervals, [A, B]),
    Number >= A - 0.0001, % ������ ������ ��� ������ ���
    length(Intervals, Len),
    LastIndex is Len - 1,
    (   Index =:= LastIndex  % ������� �������� ������ ������ ����
    ->  Number =< B + 0.0001
    ;   Number < B + 0.0001
    ),
    nth0(Index, Alphabet, Letter).

% ���������� ����������� ���� � �������������
linguistic_sequence(Numbers, Intervals, Alphabet, Sequence) :-
    maplist(assign_letter_with_debug(Intervals, Alphabet), Numbers, Sequence).

% ��������� �������� ��� ������������
assign_letter_with_debug(Intervals, Alphabet, Number, Letter) :-
    assign_letter(Number, Intervals, Alphabet, Letter).

% �������� ������� ��������
transition_matrix(Sequence, Alphabet, Matrix) :-
    (   Sequence = []
    ->  Matrix = []
    ;   findall(Row, (member(From, Alphabet), findall(Count, (member(To, Alphabet), transitions(Sequence, From, To, Count)), Row)), Matrix)
    ).

% ϳ�������� �������� �� �������
transitions(Sequence, From, To, Count) :-
    findall(1, (nextto(From, To, Sequence)), Ones),
    length(Ones, Count).

% �������� �������� �� �������������
main :-
    write('������ ��������� �������: '),
    read_line_to_string(user_input, NStr),
    (   number_string(N, NStr), integer(N), N > 0
    ->  write('��������� �������: '), write(N), nl,
        alphabet_power(N, Alphabet),
        write('������ �������� ��� ����� ������ (����� ������� ��������): '),
        read_numbers(Numbers),
        write('������ �����: '), write(Numbers), nl,
        sorted_numbers(Numbers, Sorted),
        (   Sorted = []
        ->  write('�������: �� ������� ������� �����'), nl, fail
        ;   [Min|_] = Sorted,
            reverse(Sorted, [Max|_]),
            write('Min: '), write(Min), write(', Max: '), write(Max), nl,
            intervals(N, Min, Max, Intervals),
            write('���������: '), write(Intervals), nl,
            linguistic_sequence(Numbers, Intervals, Alphabet, Sequence),
            write('����������� ����: '), write(Sequence), nl,
            (   Sequence = []
            ->  write('�������: �� ������� ���������� ����������� ����'), nl, fail
            ;   atomic_list_concat(Sequence, LinguisticString),
                write('˳���������� ���: '), write(LinguisticString), nl,
                transition_matrix(Sequence, Alphabet, Matrix),
                write('���������� �������: '), write(Matrix), nl,
                (   Matrix = []
                ->  write('�������: ������� �������� �������'), nl, fail
                ;   write('������� ��������:'), nl,
                    print_matrix(Matrix, Alphabet)
                )
            )
        )
    ;   write('�������: ��������� ������� �� ���� �������� ����� ������'), nl, fail
    ).

% ��������� ������� � ���������� ������
print_matrix(Matrix, Alphabet) :-
    write('  '), maplist(write, Alphabet), nl,
    length(Alphabet, Len),
    length(Indices, Len),
    maplist(=(0), Indices), % ��������� ������ ������� [0,0,...,0]
    maplist(print_row(Alphabet), Matrix, Indices).

% ��������� ����� �������
print_row(Alphabet, Row, Index) :-
    nth0(Index, Alphabet, Char),
    write(Char), write(' '),
    maplist(write_with_space, Row), nl,
    NextIndex is Index + 1.

% ��������� �������� ��� ��������� ����� �� �������
write_with_space(Num) :-
    write(Num), write(' ').
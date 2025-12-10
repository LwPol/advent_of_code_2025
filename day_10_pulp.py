from pulp import *
import sys
import re


variables = [LpVariable(f'x{idx}', 0, int(bound), 'Integer') for idx, bound in enumerate(sys.argv[1:])]
problem = LpProblem("day_10", LpMinimize)
while True:
    try:
        expr = input()
        equals_part_idx = expr.find('==')
        if equals_part_idx == -1:
            raise RuntimeError('Bad expression: ' + expr)
        equals_part = expr[equals_part_idx:]
        left_part = expr[:equals_part_idx]
        python_expr = re.sub(r'(\d+)', r'variables[\1]', left_part) + equals_part
        problem += eval(python_expr)
    except EOFError:
        break

problem += eval('+'.join(f'variables[{idx}]' for idx in range(len(variables))))
stat = problem.solve()
value = sum(var.value() for var in variables)
print(f'Solution: {int(value)}')

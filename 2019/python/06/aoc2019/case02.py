
def get_path(paths, token):
    result = [ token ]
    while token != 'COM':
        token = paths[token]
        result.append(token)
    
    result.reverse()
    return result

def count(input):
    paths = {}

    for x in input:
        paths[x[1]] = x[0]
    
    you = get_path(paths, 'YOU')
    san = get_path(paths, 'SAN')

    #print(you)
    #print(san)

    i = 0
    while i < len(you) and i < len(san) and you[i] == san[i]:
        i += 1
    
    return len(you) - i + len(san) - i - 2

#!/usr/bin/env python3
import csv,json,datetime,os
D=os.path.dirname(os.path.abspath(__file__))
def load(path,col):
    try: rows=list(csv.DictReader(open(path)))
    except FileNotFoundError: rows=[]
    runs=sorted({r['fetched_at'] for r in rows})
    by={t:[r for r in rows if r['fetched_at']==t] for t in runs}
    def p(r):
        try: return float(r[col])
        except: return None
    latest=by[runs[-1]] if runs else []
    prev={}
    if len(runs)>1:
        for r in by[runs[-2]]: prev[r['station_id']]=p(r)
    st=[]
    for r in latest:
        v=p(r);pv=prev.get(r['station_id'])
        st.append(dict(brand=r['brand'],street=r['street'],city=r['city'],price=v,
          diff=None if v is None or pv is None else round(v-pv,3)))
    st.sort(key=lambda s:(s['price'] is None,s['price'] or 0))
    cheap=[{'t':t,'p':min([p(r) for r in by[t] if p(r)] or [None])} for t in runs]
    return {'at':runs[-1] if runs else None,'prev_at':runs[-2] if len(runs)>1 else None,
            'stations':st,'cheapest':[c for c in cheap if c['p']]}
dz=load('/workspace/diesel-kleve/history.csv','diesel_eur_l')
e5=load('/workspace/diesel-kleve/history_e5.csv','e5_eur_l')
oil=[]
try:
    for r in csv.DictReader(open('/workspace/oil-price/history.csv')):
        f=lambda k:float(r[k]) if r.get(k) not in (None,'','.') else None
        oil.append({'d':r['date'],'brent':f('brent'),'wti':f('wti')})
except FileNotFoundError: pass
json.dump({'generated':datetime.datetime.now().astimezone().isoformat(timespec='minutes'),
 'diesel_at':dz['at'],'prev_at':dz['prev_at'],'stations':dz['stations'],'cheapest':dz['cheapest'],
 'fuels':{'diesel':dz,'e5':e5},'oil':oil},open(D+'/data.json','w'))
print('ok',len(dz['stations']),len(e5['stations']),len(oil))

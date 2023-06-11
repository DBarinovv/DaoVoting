from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
from Crypto import Random

def generate_keys():
    key = RSA.generate(2048)
    private_key = key.export_key()
    public_key = key.publickey().export_key()
    return private_key, public_key

def blind_vote(vote, public_key):
    r = Random.new().read
    m = SHA256.new(str(vote).encode('utf-8'))
    m_blinded = m.blind(r, public_key)
    return m, m_blinded, r

def sign_vote(m_blinded, private_key):
    key = RSA.import_key(private_key)
    signature = pkcs1_15.new(key).sign(m_blinded)
    return signature

def unblind_vote(signature, m, r, public_key):
    key = RSA.import_key(public_key)
    m_unblinded = m.unblind(signature, r)
    return m_unblinded

def verify_vote(m_unblinded, public_key):
    key = RSA.import_key(public_key)
    try:
        pkcs1_15.new(key).verify(m, m_unblinded)
        print("Signature is valid.")
    except (ValueError, TypeError):
        print("Signature is not valid.")

if __name__ == "__main__":
    private_key, public_key = generate_keys()
    vote = 1
    m, m_blinded, r = blind_vote(vote, public_key)
    signature = sign_vote(m_blinded, private_key)
    m_unblinded = unblind_vote(signature, m, r, public_key)
    verify_vote(m_unblinded, public_key)

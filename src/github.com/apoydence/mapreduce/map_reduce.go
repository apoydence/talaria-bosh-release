package mapreduce

type File interface {
	Length() uint64
}

type FileSystem interface {
	FetchFile(opts []CalculateOption) File
}

type Network interface {
}

type CalculateOption func(m map[string]interface{})

type MapReduce struct {
	fs        FileSystem
	network   Network
	functions []function
}

func New(fs FileSystem, network Network, chain ChainLink) *MapReduce {
	functions := chain.functions()
	return &MapReduce{
		fs:        fs,
		network:   network,
		functions: functions,
	}
}

func Calculate(opts ...CalculateOption) [][]byte {

	return nil
}

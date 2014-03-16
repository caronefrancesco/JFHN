//
//  JRFFeatureExtractor.m
//  JFHN
//
//  Created by Jack Flintermann on 3/4/14.
//  Copyright (c) 2014 Jack Flintermann. All rights reserved.
//

#import "JRFFeatureExtractor.h"
#import "JRFEntry.h"
#import <MFPPorterStemmer/MFPPorterStemmer.h>

@interface NSArray(Chunked)
- (NSArray *)pairs;
@end

@implementation NSArray(Chunked)

- (NSArray *)pairs {
    if (self.count < 2) {
        return @[];
    }
    NSMutableArray *pairs = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
            [pairs addObject:@[self[idx-1], obj]];
        }
    }];
    return pairs;
}

@end

@interface JRFFeatureExtractor() {
    NSSet *_stopWords;
}
@property(nonatomic) JRFEntry *entry;
@end

@implementation JRFFeatureExtractor

- (instancetype) initWithEntry:(JRFEntry *)entry {
    self = [super init];
    if (self) {
        _entry = entry;
    }
    return self;
}

- (NSSet *)features {
    NSMutableSet *features = [NSMutableSet set];
    [features addObjectsFromArray:[self wordFeatures]];
    [features addObjectsFromArray:[self bigramFeatures]];
    [features addObject:[self domainFeature]];
    [features addObject:[self usernameFeature]];
    [features addObject:[self dollarAmountFeature]];
    [features addObject:[self typeFeature]];
    return [NSSet setWithSet:features];
}

- (NSString *) domainFeature {
    return [NSString stringWithFormat:@"domain_%@", self.entry.domain];
}

- (NSArray *)wordFeatures {
    NSArray *words = [[self normalizedTitle] componentsSeparatedByString:@" "];
    NSMutableArray *features = [NSMutableArray array];
    [words enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *stem = [MFPPorterStemmer stemFromString:obj];
        if (![[self stopwords] containsObject:stem]) {
            [features addObject:[NSString stringWithFormat:@"word_%@", stem]];
        }
    }];
    return features;
}

- (NSArray *)bigramFeatures {
    NSArray *words = [[self normalizedTitle] componentsSeparatedByString:@" "];
    NSArray *bigrams = [words pairs];
    NSMutableArray *features = [NSMutableArray array];
    [bigrams enumerateObjectsUsingBlock:^(NSArray *pair, NSUInteger idx, BOOL *stop) {
        NSString *stem1 = [MFPPorterStemmer stemFromString:pair[0]];
        NSString *stem2 = [MFPPorterStemmer stemFromString:pair[1]];
        if (![[self stopwords] containsObject:stem1] && ![[self stopwords] containsObject:stem2]) {
            [features addObject:[NSString stringWithFormat:@"bigram_%@_%@", stem1, stem2]];
        }
    }];
    return features;
}

- (NSString *)usernameFeature {
    return [NSString stringWithFormat:@"author_%@", self.entry.authorName];
}

- (NSString *)dollarAmountFeature {
    return ([self.entry.title rangeOfString:@"$"].location == NSNotFound) ? @"dollar_NO" : @"dollar_YES";
}

- (NSString *) typeFeature {
    return [NSString stringWithFormat:@"type_%i", self.entry.type];
}

- (NSString *)normalizedTitle {
    return [[[[self.entry.title componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSSet *)stopwords {
    if (!_stopWords) {
        NSArray *words = @[
                           @"-",
                           @"a",
                           @"about",
                           @"above",
                           @"after",
                           @"again",
                           @"against",
                           @"all",
                           @"am",
                           @"an",
                           @"and",
                           @"any",
                           @"are",
                           @"aren't",
                           @"as",
                           @"at",
                           @"be",
                           @"because",
                           @"been",
                           @"before",
                           @"being",
                           @"below",
                           @"between",
                           @"both",
                           @"but",
                           @"by",
                           @"can't",
                           @"cannot",
                           @"could",
                           @"couldn't",
                           @"did",
                           @"didn't",
                           @"do",
                           @"does",
                           @"doesn't",
                           @"doing",
                           @"don't",
                           @"down",
                           @"during",
                           @"each",
                           @"few",
                           @"for",
                           @"from",
                           @"further",
                           @"had",
                           @"hadn't",
                           @"has",
                           @"hasn't",
                           @"have",
                           @"haven't",
                           @"having",
                           @"he",
                           @"he'd",
                           @"he'll",
                           @"he's",
                           @"her",
                           @"here",
                           @"here's",
                           @"hers",
                           @"herself",
                           @"him",
                           @"himself",
                           @"his",
                           @"how",
                           @"how's",
                           @"i",
                           @"i'd",
                           @"i'll",
                           @"i'm",
                           @"i've",
                           @"if",
                           @"in",
                           @"into",
                           @"is",
                           @"isn't",
                           @"it",
                           @"it's",
                           @"its",
                           @"itself",
                           @"let's",
                           @"me",
                           @"more",
                           @"most",
                           @"mustn't",
                           @"my",
                           @"myself",
                           @"no",
                           @"nor",
                           @"not",
                           @"of",
                           @"off",
                           @"on",
                           @"once",
                           @"only",
                           @"or",
                           @"other",
                           @"ought",
                           @"our",
                           @"ours",
                           @"ourselves",
                           @"out",
                           @"over",
                           @"own",
                           @"same",
                           @"shan't",
                           @"she",
                           @"she'd",
                           @"she'll",
                           @"she's",
                           @"should",
                           @"shouldn't",
                           @"so",
                           @"some",
                           @"such",
                           @"than",
                           @"that",
                           @"that's",
                           @"the",
                           @"their",
                           @"theirs",
                           @"them",
                           @"themselves",
                           @"then",
                           @"there",
                           @"there's",
                           @"these",
                           @"they",
                           @"they'd",
                           @"they'll",
                           @"they're",
                           @"they've",
                           @"this",
                           @"those",
                           @"through",
                           @"to",
                           @"too",
                           @"under",
                           @"until",
                           @"up",
                           @"very",
                           @"was",
                           @"wasn't",
                           @"we",
                           @"we'd",
                           @"we'll",
                           @"we're",
                           @"we've",
                           @"were",
                           @"weren't",
                           @"what",
                           @"what's",
                           @"when",
                           @"when's",
                           @"where",
                           @"where's",
                           @"which",
                           @"while",
                           @"who",
                           @"who's",
                           @"whom",
                           @"why",
                           @"why's",
                           @"with",
                           @"won't",
                           @"would",
                           @"wouldn't",
                           @"you",
                           @"you'd",
                           @"you'll",
                           @"you're",
                           @"you've",
                           @"your",
                           @"yours",
                           @"yourself",
                           @"yourselves"
                           ];
        NSMutableSet *stems = [NSMutableSet set];
        [words enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *stem = [MFPPorterStemmer stemFromString:obj];
            [stems addObject:stem];
        }];
        _stopWords = [NSSet setWithSet:stems];
    }
    return _stopWords;
}

@end
